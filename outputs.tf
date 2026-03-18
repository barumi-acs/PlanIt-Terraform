# ============================================
# VPC Outputs
# ============================================
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = module.vpc.vpc_arn
}

# ============================================
# Subnet Outputs
# ============================================
output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.subnets.public_subnet_ids
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDR blocks"
  value       = module.subnets.public_subnet_cidrs
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.subnets.private_subnet_ids
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDR blocks"
  value       = module.subnets.private_subnet_cidrs
}

output "all_subnet_ids" {
  description = "List of all subnet IDs"
  value       = module.subnets.all_subnet_ids
}

# ============================================
# Gateway Outputs
# ============================================
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = module.nat_gateway.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = module.nat_gateway.nat_gateway_public_ip
}

# ============================================
# Route Table Outputs
# ============================================
output "public_route_table_id" {
  description = "The ID of the public route table"
  value       = module.route_tables.public_route_table_id
}

output "private_route_table_id" {
  description = "The ID of the private route table"
  value       = module.route_tables.private_route_table_id
}

# ============================================
# EKS-related Outputs
# ============================================
output "eks_cluster_name" {
  description = "The name of the EKS cluster configured in subnet tags"
  value       = var.eks_cluster_name
}

output "eks_subnet_ids" {
  description = "List of subnet IDs tagged for EKS cluster"
  value       = module.subnets.all_subnet_ids
}

# ============================================
# Security Group Outputs
# ============================================
output "bastion_security_group_id" {
  description = "The ID of the bastion security group"
  value       = aws_security_group.bastion.id
}

# ============================================
# EC2 Outputs
# ============================================
output "bastion_instance_id" {
  description = "The ID of the bastion instance"
  value       = var.create_bastion_instance ? aws_instance.bastion[0].id : null
}

output "bastion_public_ip" {
  description = "The public IP of the bastion instance"
  value       = var.create_bastion_instance ? aws_instance.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "The private IP of the bastion instance"
  value       = var.create_bastion_instance ? aws_instance.bastion[0].private_ip : null
}

# ============================================
# Route53 Outputs
# ============================================
output "route53_zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = var.create_route53_zone ? aws_route53_zone.main[0].zone_id : null
}

output "route53_name_servers" {
  description = "The name servers for the Route53 hosted zone"
  value       = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : null
}

# ============================================
# ACM Outputs
# ============================================
output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = var.create_acm_certificate ? aws_acm_certificate.main[0].arn : null
}

output "acm_certificate_status" {
  description = "The status of the ACM certificate"
  value       = var.create_acm_certificate ? aws_acm_certificate.main[0].status : null
}

# ============================================
# S3 Outputs
# ============================================
output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.main[0].id : null
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.main[0].arn : null
}

output "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = var.create_s3_bucket ? aws_s3_bucket.main[0].bucket_domain_name : null
}

# ============================================
# EKS Cluster Outputs
# ============================================
output "eks_cluster_id" {
  description = "The ID of the EKS cluster"
  value       = module.eks.cluster_id
}

output "eks_cluster_arn" {
  description = "The ARN of the EKS cluster"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "The endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_certificate_authority" {
  description = "The certificate authority data for the EKS cluster"
  value       = module.eks.cluster_certificate_authority
  sensitive   = true
}

output "eks_cluster_version" {
  description = "The Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "The security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "eks_cluster_iam_role_arn" {
  description = "The IAM role ARN used by the EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

# ============================================
# EKS Node Group Outputs
# ============================================
output "eks_node_group_id" {
  description = "The ID of the EKS node group"
  value       = module.eks.node_group_id
}

output "eks_node_group_arn" {
  description = "The ARN of the EKS node group"
  value       = module.eks.node_group_arn
}

output "eks_node_group_status" {
  description = "The status of the EKS node group"
  value       = module.eks.node_group_status
}

output "eks_node_group_security_group_id" {
  description = "The security group ID attached to the EKS node group"
  value       = module.eks.node_group_security_group_id
}

output "eks_node_group_iam_role_arn" {
  description = "The IAM role ARN used by the EKS node group"
  value       = module.eks.node_group_iam_role_arn
}

output "eks_node_group_resources" {
  description = "Resources associated with the EKS node group"
  value       = module.eks.node_group_resources
}

# ============================================
# EKS Configuration Commands
# ============================================
output "eks_kubeconfig_command" {
  description = "Command to configure kubectl for the EKS cluster"
  value       = module.eks.kubeconfig_command
}

output "secrets_manager_arn" {
  value = module.secrets.secret_arn
}

output "secrets_irsa_role_arn" {
  value = module.secrets.irsa_role_arn
}

output "acm_certificate_arn" {
  description = "ACM Certificate ARN"
  value       = local.acm_certificate_arn
}

output "route53_zone_id" {
  description = "Route53 Hosted Zone ID"
  value       = var.create_acm_certificate ? module.acm[0].route53_zone_id : var.route53_zone_id
}

output "route53_name_servers" {
  description = "Route53 Name Servers (if zone was created)"
  value       = var.create_acm_certificate && var.create_route53_zone ? module.acm[0].route53_name_servers : []
}
