
resource "aws_grafana_workspace" "watchdog" {
  name                     = "${var.name_prefix}-grafana"
  account_access_type      = "CURRENT_ACCOUNT" # Only this AWS account
  authentication_providers = ["AWS_SSO"]       
  permission_type          = "SERVICE_MANAGED"
  role_arn = aws_iam_role.grafana_role.arn
  data_sources = [ "CLOUDWATCH" ]
  
}

resource "aws_iam_role" "grafana_role" {
  name = "grafana-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "grafana.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_cloudwatch" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

