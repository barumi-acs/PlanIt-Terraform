output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_data" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_name" {
  value = aws_eks_node_group.this.node_group_name
}

output "lbc_role_arn" {
  value = aws_iam_role.lbc.arn
}

output "external_dns_role_arn" {
  value = aws_iam_role.external_dns.arn
}

output "app_services_role_arn" {
  description = "IAM Role ARN for application services (Strategy, InsightAI) to access Bedrock and DynamoDB"
  value       = aws_iam_role.app_services.arn
}

output "oidc_provider_arn" {
  description = "EKS OIDC provider ARN for IRSA"
  value       = aws_iam_openid_connect_provider.eks.arn
}

output "oidc_issuer" {
  description = "EKS OIDC issuer URL (without https://) for IRSA"
  value       = local.oidc_issuer
}
