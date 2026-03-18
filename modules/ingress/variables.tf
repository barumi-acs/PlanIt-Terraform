variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
  default     = "planit-dev"
}

variable "domain_name" {
  description = "Domain name for ingress"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  type        = string
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  type        = string
}

variable "cognito_alb_client_id" {
  description = "Cognito Client ID for ALB"
  type        = string
}

variable "cognito_domain" {
  description = "Cognito domain"
  type        = string
}
