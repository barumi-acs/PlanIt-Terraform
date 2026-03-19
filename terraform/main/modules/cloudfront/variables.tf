variable "bucket_domain_name" {
  description = "S3 bucket domain name"
  type        = string
}

variable "project_name" {
  type = string
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for CloudFront"
  type        = string
}

variable "aliases" {
  description = "Domain aliases for CloudFront"
  type        = list(string)
  default     = ["barumi-planit.store"]
}