# ──────────────────────────────────────────────────────────
# SNS Topics for Alerting (Hybrid Approach)
# ──────────────────────────────────────────────────────────

# Critical 알림 (모든 서비스의 Critical 알림)
resource "aws_sns_topic" "alert_critical" {
  name = "${var.project_name}-alert-critical"

  tags = {
    Name        = "${var.project_name}-alert-critical"
    Environment = var.environment
    Type        = "critical"
  }
}

# User Service 알림
resource "aws_sns_topic" "alert_user" {
  name = "${var.project_name}-alert-user"

  tags = {
    Name        = "${var.project_name}-alert-user"
    Environment = var.environment
    Service     = "user"
  }
}

# Schedule Service 알림
resource "aws_sns_topic" "alert_schedule" {
  name = "${var.project_name}-alert-schedule"

  tags = {
    Name        = "${var.project_name}-alert-schedule"
    Environment = var.environment
    Service     = "schedule"
  }
}

# Strategy Service 알림
resource "aws_sns_topic" "alert_strategy" {
  name = "${var.project_name}-alert-strategy"

  tags = {
    Name        = "${var.project_name}-alert-strategy"
    Environment = var.environment
    Service     = "strategy"
  }
}

# Insight Service 알림
resource "aws_sns_topic" "alert_insight" {
  name = "${var.project_name}-alert-insight"

  tags = {
    Name        = "${var.project_name}-alert-insight"
    Environment = var.environment
    Service     = "insight"
  }
}

# InsightAI Service 알림
resource "aws_sns_topic" "alert_insightai" {
  name = "${var.project_name}-alert-insightai"

  tags = {
    Name        = "${var.project_name}-alert-insightai"
    Environment = var.environment
    Service     = "insightai"
  }
}

# ──────────────────────────────────────────────────────────
# Lambda Function for Slack Forwarding
# ──────────────────────────────────────────────────────────

# Lambda 실행 Role
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "slack_forwarder" {
  name               = "${var.project_name}-Slack-Forwarder-Role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    Name = "${var.project_name}-Slack-Forwarder-Role"
  }
}

# CloudWatch Logs 권한
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.slack_forwarder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda 함수 코드 압축
data "archive_file" "slack_forwarder" {
  type        = "zip"
  output_path = "${path.module}/slack-forwarder.zip"

  source {
    content  = file("${path.module}/slack-forwarder.py")
    filename = "slack-forwarder.py"
  }
}

# Lambda 함수
resource "aws_lambda_function" "slack_forwarder" {
  filename         = data.archive_file.slack_forwarder.output_path
  function_name    = "${var.project_name}-slack-forwarder"
  role             = aws_iam_role.slack_forwarder.arn
  handler          = "slack-forwarder.lambda_handler"
  source_code_hash = data.archive_file.slack_forwarder.output_base64sha256
  runtime          = "python3.11"
  timeout          = 30

  environment {
    variables = {
      SLACK_WEBHOOK_CRITICAL  = var.slack_webhook_critical
      SLACK_WEBHOOK_USER      = var.slack_webhook_user
      SLACK_WEBHOOK_SCHEDULE  = var.slack_webhook_schedule
      SLACK_WEBHOOK_STRATEGY  = var.slack_webhook_strategy
      SLACK_WEBHOOK_INSIGHT   = var.slack_webhook_insight
      SLACK_WEBHOOK_INSIGHTAI = var.slack_webhook_insightai
    }
  }

  tags = {
    Name = "${var.project_name}-slack-forwarder"
  }
}

# ──────────────────────────────────────────────────────────
# SNS → Lambda 구독
# ──────────────────────────────────────────────────────────

# Lambda 권한 부여 (SNS가 Lambda 호출 가능하도록)
resource "aws_lambda_permission" "allow_sns_critical" {
  statement_id  = "AllowExecutionFromSNSCritical"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_forwarder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alert_critical.arn
}

resource "aws_lambda_permission" "allow_sns_user" {
  statement_id  = "AllowExecutionFromSNSUser"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_forwarder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alert_user.arn
}

resource "aws_lambda_permission" "allow_sns_schedule" {
  statement_id  = "AllowExecutionFromSNSSchedule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_forwarder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alert_schedule.arn
}

resource "aws_lambda_permission" "allow_sns_strategy" {
  statement_id  = "AllowExecutionFromSNSStrategy"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_forwarder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alert_strategy.arn
}

resource "aws_lambda_permission" "allow_sns_insight" {
  statement_id  = "AllowExecutionFromSNSInsight"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_forwarder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alert_insight.arn
}

resource "aws_lambda_permission" "allow_sns_insightai" {
  statement_id  = "AllowExecutionFromSNSInsightAI"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.slack_forwarder.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.alert_insightai.arn
}

# SNS 구독
resource "aws_sns_topic_subscription" "critical_to_lambda" {
  topic_arn = aws_sns_topic.alert_critical.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_forwarder.arn

  depends_on = [aws_lambda_permission.allow_sns_critical]
}

resource "aws_sns_topic_subscription" "user_to_lambda" {
  topic_arn = aws_sns_topic.alert_user.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_forwarder.arn

  depends_on = [aws_lambda_permission.allow_sns_user]
}

resource "aws_sns_topic_subscription" "schedule_to_lambda" {
  topic_arn = aws_sns_topic.alert_schedule.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_forwarder.arn

  depends_on = [aws_lambda_permission.allow_sns_schedule]
}

resource "aws_sns_topic_subscription" "strategy_to_lambda" {
  topic_arn = aws_sns_topic.alert_strategy.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_forwarder.arn

  depends_on = [aws_lambda_permission.allow_sns_strategy]
}

resource "aws_sns_topic_subscription" "insight_to_lambda" {
  topic_arn = aws_sns_topic.alert_insight.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_forwarder.arn

  depends_on = [aws_lambda_permission.allow_sns_insight]
}

resource "aws_sns_topic_subscription" "insightai_to_lambda" {
  topic_arn = aws_sns_topic.alert_insightai.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.slack_forwarder.arn

  depends_on = [aws_lambda_permission.allow_sns_insightai]
}


# ──────────────────────────────────────────────────────────
# CloudWatch Billing Alarm
# ──────────────────────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "billing" {
  alarm_name          = "${var.project_name}-billing-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400 # 24시간
  statistic           = "Maximum"
  threshold           = var.billing_threshold
  alarm_description   = "Alert when estimated charges exceed ${var.billing_threshold} USD"
  alarm_actions       = [aws_sns_topic.alert_critical.arn]

  dimensions = {
    Currency = "USD"
  }

  tags = {
    Name = "${var.project_name}-billing-alarm"
  }
}
