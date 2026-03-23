variable "project_name" {
  description = "프로젝트 이름"
  type        = string
}

variable "environment" {
  description = "환경 (dev, staging, prod)"
  type        = string
}

variable "bucket_name" {
  description = "S3 버킷 이름 (예: barumi-loki-dev)"
  type        = string
}

variable "retention_days" {
  description = "로그 보관 기간 (일)"
  type        = number
  default     = 90
}
