# ============================================
# EKS Module Outputs
# ============================================
# 외부로 내보낼 정보 (Cluster Endpoint, Security Group ID 등)

# ============================================
# EKS Cluster Outputs
# ============================================

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].id : null
}

output "cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].arn : null
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].name : null
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].endpoint : null
}

output "cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].certificate_authority[0].data : null
  sensitive   = true
}

output "cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = var.create_eks_cluster ? aws_eks_cluster.main[0].version : null
}

output "cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster"
  value       = var.create_eks_cluster ? aws_security_group.eks_cluster[0].id : null
}

output "cluster_iam_role_arn" {
  description = "The IAM role ARN used by the EKS cluster"
  value       = var.create_eks_cluster ? aws_iam_role.eks_cluster[0].arn : null
}

output "cluster_iam_role_name" {
  description = "The IAM role name used by the EKS cluster"
  value       = var.create_eks_cluster ? aws_iam_role.eks_cluster[0].name : null
}

# ============================================
# EKS Node Group Outputs
# ============================================

output "node_group_id" {
  description = "The ID of the EKS node group"
  value       = var.create_eks_cluster ? aws_eks_node_group.main[0].id : null
}

output "node_group_arn" {
  description = "The ARN of the EKS node group"
  value       = var.create_eks_cluster ? aws_eks_node_group.main[0].arn : null
}

output "node_group_status" {
  description = "The status of the EKS node group"
  value       = var.create_eks_cluster ? aws_eks_node_group.main[0].status : null
}

output "node_group_security_group_id" {
  description = "The security group ID attached to the EKS node group"
  value       = var.create_eks_cluster ? aws_security_group.eks_node_group[0].id : null
}

output "node_group_iam_role_arn" {
  description = "The IAM role ARN used by the EKS node group"
  value       = var.create_eks_cluster ? aws_iam_role.eks_node_group[0].arn : null
}

output "node_group_iam_role_name" {
  description = "The IAM role name used by the EKS node group"
  value       = var.create_eks_cluster ? aws_iam_role.eks_node_group[0].name : null
}

output "node_group_resources" {
  description = "Resources associated with the EKS node group"
  value       = var.create_eks_cluster ? aws_eks_node_group.main[0].resources : null
}

# ============================================
# Configuration Commands
# ============================================

output "kubeconfig_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = var.create_eks_cluster ? "aws eks update-kubeconfig --region ${data.aws_region.current.name} --name ${aws_eks_cluster.main[0].name}" : null
}

# ============================================
# Data Sources
# ============================================

data "aws_region" "current" {}
