resource "aws_s3_bucket" "falco_rules" {
  bucket = "${var.name_prefix}-falco-rules"

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