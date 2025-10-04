# ------------------------------
# CloudWatch Log Group (for Lambda)
# ------------------------------
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/my-lambda-function"
  retention_in_days = 14
}

# ------------------------------
# Metric Filter for 'ERROR' logs
# ------------------------------
resource "aws_cloudwatch_log_metric_filter" "error_metric_filter" {
  name           = "jibin-LambdaErrorCount"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "jibin-LambdaErrorCount"
    namespace = "MyLambdaMetrics"
    value     = "1"
  }
}

# ------------------------------
# CloudWatch Alarm for the Metric
# ------------------------------
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "jibin-LambdaErrorAlarm"
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

# ------------------------------
# SNS Topic for Alarm Notifications
# ------------------------------
resource "aws_sns_topic" "lambda_alarm_topic" {
  name = "jibin-error-alarm-topic"
}

# Optional: Email subscription for notifications
resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.lambda_alarm_topic.arn
  protocol  = "email"
  endpoint  = "perseverancejbt@hotmail.com"
}
