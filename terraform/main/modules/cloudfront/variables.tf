variable "acm_certificate_arn" {
  description = "CloudFront용 ACM 인증서 ARN"
  type        = string
}

variable "aliases" {
  description = "CloudFront 도메인 alias 목록"
  type        = list(string)
}
variable "bucket_domain_name" {
  description = "S3 bucket domain name"
  type        = string
}

variable "project_name" {
  type = string
}
variable "acm_certificate_arn_SEOUL" {
  description = "서울 리전 ACM 인증서 ARN"
  type        = string
}
