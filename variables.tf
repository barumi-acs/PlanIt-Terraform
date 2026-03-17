variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-2"
}

variable "project_name" {
  description = "Project prefix for naming"
  type        = string
  default     = "PI-DEV"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "PI-DEV-Cluster"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.230.0.0/16"
}

variable "public_subnet_2a_cidr" {
  description = "Public subnet CIDR in az 2a"
  type        = string
  default     = "10.230.4.0/24"
}

variable "public_subnet_2c_cidr" {
  description = "Public subnet CIDR in az 2c"
  type        = string
  default     = "10.230.5.0/24"
}

variable "eks_private_subnet_2a_cidr" {
  description = "EKS private subnet CIDR in az 2a"
  type        = string
  default     = "10.230.1.0/24"
}

variable "eks_private_subnet_2c_cidr" {
  description = "EKS private subnet CIDR in az 2c"
  type        = string
  default     = "10.230.2.0/24"
}

variable "db_private_subnet_2a_cidr" {
  description = "DB private subnet CIDR in az 2a"
  type        = string
  default     = "10.230.6.0/24"
}

variable "db_private_subnet_2c_cidr" {
  description = "DB private subnet CIDR in az 2c"
  type        = string
  default     = "10.230.7.0/24"
}

variable "admin_cidr" {
  description = "Your laptop public CIDR for bastion SSH (e.g., 1.2.3.4/32)"
  type        = string

  validation {
    condition     = length(trimspace(var.admin_cidr)) > 0 && can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a non-empty valid IPv4 CIDR (example: 203.0.113.10/32)."
  }
}

variable "node_instance_types" {
  description = "EKS node instance types"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired EKS node count"
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum EKS node count"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum EKS node count"
  type        = number
  default     = 3
}

variable "db_name" {
  description = "Initial MariaDB database name"
  type        = string
  default     = "planit_user_db"
}

variable "db_username" {
  description = "MariaDB master username"
  type        = string
  default     = "root"
}

variable "db_password" {
  description = "MariaDB master password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8 && length(var.db_password) <= 41
    error_message = "db_password must be between 8 and 41 characters."
  }
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_engine_version" {
  description = "MariaDB engine version"
  type        = string
  default     = "10.11.9"
}

variable "planit_db_names" {
  description = "Additional application databases to create in MariaDB"
  type        = list(string)
  default = [
    "planit_insight_db",
    "planit_schedule_db",
    "planit_strategy_db",
    "planit_user_db"
  ]
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "pi-dev-bareunbaleum-s3"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name"
  type        = string
  default     = "PI-DEV-Insight-Dynamo"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "PI-DEV"
    Environment = "dev"
  }
}
