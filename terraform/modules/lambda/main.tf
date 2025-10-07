# main lambda
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "./modules/lambda/src/lambda_function.py"
  output_path = "./modules/lambda/build/lambda_function.zip"
}

resource "aws_lambda_function" "tagger_handler" {
  function_name = "${var.name_prefix}-tagger-function"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.13"
  role          = var.tagger_role_arn

  filename            = data.archive_file.lambda_zip.output_path
  source_code_hash    = data.archive_file.lambda_zip.output_base64sha256
  timeout             = 30

  environment {
    variables = {
      FALCO_LOG_GROUP = var.falco_log_group_name
    }
  }

}


resource "aws_cloudwatch_event_rule" "scheduled_scan" {
  name                = "falco-scheduled-scan"
  description         = "Trigger Falco tagger every 2 minutes"
  schedule_expression = "rate(${var.instance_scan_interval} minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.scheduled_scan.name
  target_id = "FalcoTaggerLambda"
  arn       = aws_lambda_function.tagger_handler.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tagger_handler.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduled_scan.arn
}