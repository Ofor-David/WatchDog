resource "aws_s3_bucket" "falco_rules" {
  bucket = "${var.name_prefix}-falco-rules-bucket"

  tags = {
    Name    = "FalcoRulesBucket"
    Project = var.name_prefix
  }
}
resource "aws_s3_bucket_versioning" "falco_rules_versioning" {
  bucket = aws_s3_bucket.falco_rules.id

  versioning_configuration {
    status = "Enabled"
  }
}

# limit public access
resource "aws_s3_bucket_public_access_block" "falco_rules" {
  bucket                  = aws_s3_bucket.falco_rules.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudwatch_log_group" "falco" {
  name              = "falco-alerts"
  retention_in_days = var.retention_in_days
}

resource "aws_sns_topic" "falco_alerts" {
  name = "${var.name_prefix}-falco-alerts-topic"
}

resource "aws_cloudwatch_log_metric_filter" "filter" {
  name           = "${var.name_prefix}-falco-metric-filter"
  log_group_name = aws_cloudwatch_log_group.falco.name

  pattern = ""

  metric_transformation {
    name      = "AlertCount"
    namespace = "${var.name_prefix}/Alerts"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = "${var.name_prefix}-falco-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = aws_cloudwatch_log_metric_filter.filter.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.filter.metric_transformation[0].namespace
  period              = 300 # 5 minutes
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Alarm when falco logs are triggered"
  alarm_actions       = [aws_sns_topic.falco_alerts.arn]
}