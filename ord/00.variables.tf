variable "AWS_ACCESS_KEY_ID" {
  description = "AWS access key"
  type        = string
  default     = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
  default     = ""
}
