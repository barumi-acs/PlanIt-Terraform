variable "name_prefix" {
  description = "Prefix for NAT Gateway name"
  type        = string
}

variable "subnet_id" {
  description = "ID of the public subnet where NAT Gateway will be created"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway (for dependency)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to NAT Gateway resources"
  type        = map(string)
  default     = {}
}
