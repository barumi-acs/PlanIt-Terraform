variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix for subnet names"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "availability_zones" {
  description = "List of availability zones for subnets"
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "Name of the EKS cluster for subnet tagging"
  type        = string
}

variable "tags" {
  description = "Tags to apply to subnet resources"
  type        = map(string)
  default     = {}
}
