import os
import boto3
import logging
import re
from botocore.exceptions import ClientError

logs = boto3.client("logs")
ec2 = boto3.client("ec2")
logger = logging.getLogger()
logger.setLevel(logging.INFO)

LOG_GROUP = os.getenv("FALCO_LOG_GROUP")


def lambda_handler(event, context):
    logger.info("Scanning Falco log streams...")
    instance_ids = set()

    try:
        # List log streams in /ecs/falco-alerts
        paginator = logs.get_paginator("describe_log_streams")
        for page in paginator.paginate(logGroupName=LOG_GROUP):
            for stream in page.get("logStreams", []):
                name = stream.get("logStreamName", "")
                # Extract instance ID (supports both 8 and 17 character IDs)
                match = re.search(r"i-[a-f0-9]{8,17}", name)
                if match:
                    instance_ids.add(match.group(0))

    except ClientError as e:
        logger.error(f"Failed to list log streams: {e}")
        return {"error": "Failed to access log group", "tagged_instances": 0}

    logger.info(f"Found {len(instance_ids)} unique instances with Falco logs.")

    # Batch tagging for efficiency
    tagged_count = 0
    failed_instances = []

    for iid in instance_ids:
        try:
            # Verify instance exists before tagging
            ec2.describe_instances(InstanceIds=[iid])
            ec2.create_tags(
                Resources=[iid],
                Tags=[{"Key": "InspectionStatus", "Value": "ToBeInspected"}],
            )
            logger.info(f"Tagged {iid} as ToBeInspected")
            tagged_count += 1
        except ClientError as e:
            error_code = e.response.get("Error", {}).get("Code")
            if error_code == "InvalidInstanceID.NotFound":
                logger.warning(f"Instance {iid} no longer exists, skipping")
            else:
                logger.error(f"Failed to tag {iid}: {e}")
                failed_instances.append(iid)

    return {
        "tagged_instances": tagged_count,
        "failed_instances": failed_instances,
        "total_found": len(instance_ids),
    }
