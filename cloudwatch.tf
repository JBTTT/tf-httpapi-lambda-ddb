# ------------------------------
# CloudWatch Log Group (for Lambda)
# ------------------------------
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/moviedb-api/${aws_lambda_function.http_api_lambda.function_name}"
  retention_in_days = 14
}

# ------------------------------
# Metric Filter for 'ERROR' logs
# ------------------------------
resource "aws_cloudwatch_log_metric_filter" "error_metric_filter" {
  name           = "${local.name_prefix}-lambda-error-filter"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "${local.name_prefix}-LambdaErrorCount"
    namespace  = "/moviedb-api/${local.name_prefix}"
    value     = "1"
  }
}

# ------------------------------
# Metric Filter for 'INFO' logs
# ------------------------------
resource "aws_cloudwatch_log_metric_filter" "info_metric_filter" {
  name           = "${local.name_prefix}-lambda-info-count"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
  pattern        = "[INFO]"

  metric_transformation {
    name      = "${local.name_prefix}-LambdaInfoCount"
    namespace  = "/moviedb-api/${local.name_prefix}"
    value      = "1"
    unit       = "None"
  }
}


# ------------------------------
# CloudWatch Alarm for the Metric
# ------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "${local.name_prefix}-LambdaErrorAlarm"
  alarm_description   = "Alarm when Lambda logs contain 'ERROR'"
  namespace           = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].namespace
  metric_name         = aws_cloudwatch_log_metric_filter.error_metric_filter.metric_transformation[0].name
  comparison_operator = "GreaterThanThreshold"
  threshold           = 1
  evaluation_periods  = 1
  period              = 60
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.lambda_alarm_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "lambda_info_alarm" {
  alarm_name          = "${local.name_prefix}-LambdaInfoAlarm"
  alarm_description   = "Alarm when Lambda logs contain '[INFO]'"
  namespace           = aws_cloudwatch_log_metric_filter.info_metric_filter.metric_transformation[0].namespace
  metric_name         = aws_cloudwatch_log_metric_filter.info_metric_filter.metric_transformation[0].name
  comparison_operator = "GreaterThanThreshold"
  threshold           = 10
  evaluation_periods  = 1
  period              = 60
  unit                = "Count"
  statistic           = "Sum"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.lambda_alarm_topic.arn]
}



# ------------------------------
# SNS Topic for Alarm Notifications
# ------------------------------
resource "aws_sns_topic" "lambda_alarm_topic" {
  name = "${local.name_prefix}-error-alarm-topic"
}

# Optional: Email subscription for notifications
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.lambda_alarm_topic.arn
  protocol  = "email"
  endpoint  = "perseverancejbt@hotmail.com"
}
