variable "aws_region" {
  description = "AWS region for Terraform bootstrap resources"
  type        = string
  default     = "ap-northeast-2"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  type        = string
  default     = "planit-team-tfstate-bucket"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  type        = string
  default     = "terraform-lock"
}

variable "common_tags" {
  description = "Common tags for bootstrap resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "PlanIt"
    Environment = "dev"
  }
}
