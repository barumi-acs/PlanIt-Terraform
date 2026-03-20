variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where VPC Endpoint will be created"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "route_table_ids" {
  description = "List of Route Table IDs to associate with DynamoDB VPC Endpoint"
  type        = list(string)
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for VPC Endpoint policy"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}
