output "sns_topic_critical_arn" {
  description = "SNS Topic ARN for critical alerts"
  value       = aws_sns_topic.alert_critical.arn
}

output "sns_topic_user_arn" {
  description = "SNS Topic ARN for user service alerts"
  value       = aws_sns_topic.alert_user.arn
}

output "sns_topic_schedule_arn" {
  description = "SNS Topic ARN for schedule service alerts"
  value       = aws_sns_topic.alert_schedule.arn
}

output "sns_topic_strategy_arn" {
  description = "SNS Topic ARN for strategy service alerts"
  value       = aws_sns_topic.alert_strategy.arn
}

output "sns_topic_insight_arn" {
  description = "SNS Topic ARN for insight service alerts"
  value       = aws_sns_topic.alert_insight.arn
}

output "sns_topic_insightai_arn" {
  description = "SNS Topic ARN for insightai service alerts"
  value       = aws_sns_topic.alert_insightai.arn
}

output "lambda_function_arn" {
  description = "Lambda Function ARN for Slack forwarding"
  value       = aws_lambda_function.slack_forwarder.arn
}

output "lambda_function_name" {
  description = "Lambda Function name"
  value       = aws_lambda_function.slack_forwarder.function_name
}
