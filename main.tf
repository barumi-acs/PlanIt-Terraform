# ============================================
# VPC Module
# ============================================
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "${var.project_name}-${upper(var.environment)}-VPC"
  vpc_cidr             = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = var.common_tags
}

# ============================================
# Subnets Module
# ============================================
module "subnets" {
  source = "./modules/subnets"

  vpc_id               = module.vpc.vpc_id
  name_prefix          = "${var.project_name}-${upper(var.environment)}"
  public_subnet_cidrs  = [var.public_subnet_cidr_2a, var.public_subnet_cidr_2c ]
  private_subnet_cidrs = [var.private_subnet_cidr_2a, var.private_subnet_cidr_2c]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}c"]
  eks_cluster_name     = var.eks_cluster_name

  tags = var.common_tags
}

# ============================================
# NAT Gateway Module
# ============================================
module "nat_gateway" {
  source = "./modules/nat-gateway"

  name_prefix         = "${var.project_name}-${upper(var.environment)}"
  subnet_id           = module.subnets.public_subnet_ids[0]
  internet_gateway_id = module.vpc.internet_gateway_id

  tags = var.common_tags
}

# ============================================
# Route Tables Module
# ============================================
module "route_tables" {
  source = "./modules/route-tables"

  vpc_id              = module.vpc.vpc_id
  name_prefix         = "${var.project_name}-${upper(var.environment)}"
  internet_gateway_id = module.vpc.internet_gateway_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids

  tags = var.common_tags
}

# ============================================
# EKS Module
# ============================================
module "eks" {
  source = "./modules/eks"

  create_eks_cluster = var.create_eks_cluster
  cluster_name       = var.eks_cluster_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.subnets.private_subnet_ids

  # Cluster Configuration
  cluster_version         = var.eks_cluster_version
  endpoint_private_access = var.eks_endpoint_private_access
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs
  enabled_log_types       = var.eks_enabled_log_types
  enable_cloudwatch_logs  = var.enable_eks_cloudwatch_logs

  # Node Group Configuration
  node_desired_size      = var.eks_node_desired_size
  node_max_size          = var.eks_node_max_size
  node_min_size          = var.eks_node_min_size
  node_max_unavailable   = var.eks_node_max_unavailable
  node_instance_types    = var.eks_node_instance_types
  node_capacity_type     = var.eks_node_capacity_type
  node_disk_size         = var.eks_node_disk_size
  node_ssh_key           = var.eks_node_ssh_key
  node_ssh_source_sg_ids = var.eks_node_ssh_source_sg_ids
  node_labels            = var.eks_node_labels
  node_taints            = var.eks_node_taints

  # Add-ons Configuration
  enable_vpc_cni_addon         = var.enable_vpc_cni_addon
  vpc_cni_addon_version        = var.vpc_cni_addon_version
  enable_coredns_addon         = var.enable_coredns_addon
  coredns_addon_version        = var.coredns_addon_version
  enable_kube_proxy_addon      = var.enable_kube_proxy_addon
  kube_proxy_addon_version     = var.kube_proxy_addon_version
  enable_ebs_csi_driver        = var.enable_ebs_csi_driver
  ebs_csi_driver_addon_version = var.ebs_csi_driver_addon_version

  tags = var.common_tags
}
