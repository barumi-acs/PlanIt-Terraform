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
  default     = "1.33"
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
  default     = 2
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

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.1"
}

variable "redis_node_type" {
  description = "Redis node instance type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "Number of Redis cache nodes (1 for single node, 2+ for cluster with failover)"
  type        = number
  default     = 2
}

variable "cognito_user_pool_id" {
  description = "기존 Cognito User Pool ID"
  type        = string
}

variable "cognito_client_id" {
  description = "기존 Cognito Client ID"
  type        = string
}

variable "cognito_client_secret" {
  description = "Cognito App Client Secret (Secrets Manager에 저장)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID (Secrets Manager에 저장)"
  type        = string
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key (Secrets Manager에 저장)"
  type        = string
  sensitive   = true
}

variable "gnews_api_key" {
  description = "GNews API Key (Secrets Manager에 저장)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "jwt_secret" {
  description = "JWT secret key for all backend services"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must be at least 32 characters long for security."
  }
}

variable "acm_certificate_arn_virginia" {
  description = "ACM certificate ARN in us-east-1 for CloudFront"
  type        = string
}

variable "acm_certificate_arn_seoul" {
  description = "ACM certificate ARN in ap-northeast-2 for ALB Ingress"
  type        = string
}

variable "external_dns_domain_filters" {
  description = "Route 53 public domains managed by ExternalDNS"
  type        = list(string)
  default     = ["barumi-planit.store"]

  validation {
    condition     = length(var.external_dns_domain_filters) > 0 && alltrue([for domain in var.external_dns_domain_filters : length(trimspace(domain)) > 0])
    error_message = "external_dns_domain_filters must contain at least one non-empty domain."
  }
}

variable "route53_zone_id" {
  description = "(Optional) Route53 hosted zone ID for the domain (if provided, skips zone lookup)"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "PI-DEV"
    Environment = "dev"
  }
}

variable "frontend_bucket_name" {
  description = "S3 bucket name for frontend static files"
  type        = string
}