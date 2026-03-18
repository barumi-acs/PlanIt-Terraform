variable "project_name" {
  description = "Project name prefix"
  type        = string
}

variable "domain_name" {
  description = "Primary domain name for certificate"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names for certificate"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route53 hosted zone ID for DNS validation"
  type        = string
  default     = ""
}

variable "create_route53_zone" {
  description = "Whether to create a new Route53 hosted zone"
  type        = bool
  default     = false
}
