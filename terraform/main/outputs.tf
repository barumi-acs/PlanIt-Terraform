output "vpc_id" {
  value = module.network.vpc_id
}

output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "external_dns_role_arn" {
  value = module.eks.external_dns_role_arn
}

output "alb_sg_id" {
  value = module.security.alb_sg_id
}

# User Service RDS
output "rds_user_endpoint" {
  value       = module.rds_user.endpoint
  description = "User Service RDS endpoint"
}

# Schedule Service RDS
output "rds_schedule_endpoint" {
  value       = module.rds_schedule.endpoint
  description = "Schedule Service RDS endpoint"
}

# Strategy Service RDS
output "rds_strategy_endpoint" {
  value       = module.rds_strategy.endpoint
  description = "Strategy Service RDS endpoint"
}

# Insight Service RDS
output "rds_insight_endpoint" {
  value       = module.rds_insight.endpoint
  description = "Insight Service RDS endpoint"
}

output "s3_bucket_name" {
  value = module.s3.bucket_name
}

output "dynamodb_table_name" {
  value = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  value = module.dynamodb.table_arn
}

output "redis_endpoint" {
  description = "Redis primary endpoint address"
  value       = module.redis.redis_endpoint
}

output "redis_port" {
  description = "Redis port"
  value       = module.redis.redis_port
}

output "secrets_irsa_role_arn" {
  description = "IRSA Role ARN for Secrets Manager access (PlanIt-Yaml service-account.yaml에 사용)"
  value       = module.secrets.irsa_role_arn
}

output "secrets_secret_name" {
  description = "AWS Secrets Manager secret name"
  value       = module.secrets.secret_name
}
