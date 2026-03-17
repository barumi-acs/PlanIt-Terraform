variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for route table names"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  type        = string
}

variable "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs to associate with public route table"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs to associate with private route table"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to route table resources"
  type        = map(string)
  default     = {}
}
