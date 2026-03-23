variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}

variable "slack_webhook_critical" {
  description = "Slack Webhook URL for critical alerts"
  type        = string
  sensitive   = true
}

variable "slack_webhook_user" {
  description = "Slack Webhook URL for user service alerts"
  type        = string
  sensitive   = true
}

variable "slack_webhook_schedule" {
  description = "Slack Webhook URL for schedule service alerts"
  type        = string
  sensitive   = true
}

variable "slack_webhook_strategy" {
  description = "Slack Webhook URL for strategy service alerts"
  type        = string
  sensitive   = true
}

variable "slack_webhook_insight" {
  description = "Slack Webhook URL for insight service alerts"
  type        = string
  sensitive   = true
}

variable "slack_webhook_insightai" {
  description = "Slack Webhook URL for insightai service alerts"
  type        = string
  sensitive   = true
}

variable "billing_threshold" {
  description = "Billing alarm threshold in USD"
  type        = number
  default     = 100
}
