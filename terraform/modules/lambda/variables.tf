variable "name_prefix"{
    description = "Prefix for resource names"
    type        = string
}

variable "tagger_role_arn"{
    description = "ARN of the IAM role for the Lambda function"
    type        = string
}

variable "falco_log_group_name"{
    description = "Name of the CloudWatch log group where Falco logs are sent"
    type        = string
}
variable "instance_scan_interval"{
    description = "Interval in minutes for scanning instances"
    type        = number
}