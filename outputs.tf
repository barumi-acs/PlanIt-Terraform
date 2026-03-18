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

output "rds_endpoint" {
  value = module.rds.endpoint
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

output "secrets_irsa_role_arn" {
  description = "IRSA Role ARN for Secrets Manager access (PlanIt-Yaml service-account.yaml에 사용)"
  value       = module.secrets.irsa_role_arn
}

output "secrets_secret_name" {
  description = "AWS Secrets Manager secret name"
  value       = module.secrets.secret_name
}
