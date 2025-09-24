output "falco_bucket_name" {
  value       = aws_s3_bucket.falco_rules.bucket
  description = "Name of the S3 bucket created for Falco custom rules"
}
output "falco_bucket_arn" {
  value       = aws_s3_bucket.falco_rules.arn
  description = "ARN of the S3 bucket created for Falco custom rules"
}

output "falco_log_group_name" {
  value       = aws_cloudwatch_log_group.falco.name
  description = "Name of the falco log group that collects logs"
}
