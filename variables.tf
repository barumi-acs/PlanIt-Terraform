# AWS Credentials
variable "aws_access_key_id" {
  description = "AWS access key ID for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_access_key" {
  description = "AWS secret access key for authentication"
  type        = string
  default     = ""
  sensitive   = true
}

# Region Configuration
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-northeast-2"
}

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.230.0.0/16"
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

# Subnet Configuration
variable "public_subnet_cidr_2a" {
  description = "CIDR block for public subnet in availability zone 2a"
  type        = string
  default     = "10.230.4.0/24"
}

variable "public_subnet_cidr_2c" {
  description = "CIDR block for public subnet in availability zone 2c"
  type        = string
  default     = "10.230.5.0/24"
}

variable "private_subnet_cidr_2a" {
  description = "CIDR block for private subnet in availability zone 2a"
  type        = string
  default     = "10.230.1.0/24"
}

variable "private_subnet_cidr_2c" {
  description = "CIDR block for private subnet in availability zone 2c"
  type        = string
  default     = "10.230.2.0/24"
}

# EKS Configuration
variable "eks_cluster_name" {
  description = "Name of the EKS cluster for tagging subnets"
  type        = string
  default     = "terraform-eks-cluster"
}

# Environment and Project Tags
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "PI"
}

# Common Tags
variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "PlanIt"
    Environment = "DEV"
    ManagedBy   = "Terraform"
  }
}

# EC2 Configuration
variable "create_bastion_instance" {
  description = "Whether to create bastion/ECS instance"
  type        = bool
  default     = false
}

variable "bastion_ami" {
  description = "AMI ID for bastion instance"
  type        = string
  default     = "ami-056a29f2eddc40520"
}

variable "bastion_instance_type" {
  description = "Instance type for bastion"
  type        = string
  default     = "t2.micro"
}

variable "bastion_private_ip" {
  description = "Fixed private IP for bastion instance"
  type        = string
  default     = "10.230.4.240"
}

variable "bastion_volume_size" {
  description = "Root volume size for bastion instance (GB)"
  type        = number
  default     = 8
}

variable "ec2_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
  default     = ""
}

# Route53 Configuration
variable "create_route53_zone" {
  description = "Whether to create Route53 hosted zone"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name for Route53 and ACM certificate"
  type        = string
  default     = ""
}

# ACM Configuration
variable "create_acm_certificate" {
  description = "Whether to create ACM certificate"
  type        = bool
  default     = false
}

# S3 Configuration
variable "create_s3_bucket" {
  description = "Whether to create S3 bucket"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = ""
}

variable "enable_s3_versioning" {
  description = "Enable versioning for S3 bucket"
  type        = bool
  default     = false
}

variable "enable_s3_encryption" {
  description = "Enable encryption for S3 bucket"
  type        = bool
  default     = true
}

# ============================================
# EKS Cluster Configuration
# ============================================

variable "create_eks_cluster" {
  description = "Whether to create EKS cluster"
  type        = bool
  default     = false
}

variable "eks_cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "eks_endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "eks_endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "eks_public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "eks_enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_eks_cloudwatch_logs" {
  description = "Enable CloudWatch logs for EKS nodes"
  type        = bool
  default     = true
}

# ============================================
# EKS Node Group Configuration
# ============================================

variable "eks_node_desired_size" {
  description = "Desired number of worker nodes (for 5 microservices)"
  type        = number
  default     = 3
}

variable "eks_node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "eks_node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_unavailable" {
  description = "Maximum number of nodes unavailable during update"
  type        = number
  default     = 1
}

variable "eks_node_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_capacity_type" {
  description = "Type of capacity (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "eks_node_disk_size" {
  description = "Disk size in GB for EKS nodes"
  type        = number
  default     = 20
}

variable "eks_node_ssh_key" {
  description = "EC2 key pair name for SSH access to nodes"
  type        = string
  default     = ""
}

variable "eks_node_ssh_source_sg_ids" {
  description = "Security group IDs allowed to SSH to nodes"
  type        = list(string)
  default     = []
}

variable "eks_node_labels" {
  description = "Key-value map of Kubernetes labels for nodes"
  type        = map(string)
  default     = {}
}

variable "eks_node_taints" {
  description = "List of Kubernetes taints to apply to nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
}

variable "eks_node_bootstrap_arguments" {
  description = "Additional arguments for node bootstrap script"
  type        = string
  default     = ""
}

variable "use_custom_launch_template" {
  description = "Use custom launch template for node group"
  type        = bool
  default     = false
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed monitoring for EC2 instances"
  type        = bool
  default     = false
}

# ============================================
# EKS Add-ons Configuration
# ============================================

variable "enable_vpc_cni_addon" {
  description = "Enable VPC CNI add-on"
  type        = bool
  default     = true
}

variable "vpc_cni_addon_version" {
  description = "Version of VPC CNI add-on"
  type        = string
  default     = null
}

variable "enable_coredns_addon" {
  description = "Enable CoreDNS add-on"
  type        = bool
  default     = true
}

variable "coredns_addon_version" {
  description = "Version of CoreDNS add-on"
  type        = string
  default     = null
}

variable "enable_kube_proxy_addon" {
  description = "Enable kube-proxy add-on"
  type        = bool
  default     = true
}

variable "kube_proxy_addon_version" {
  description = "Version of kube-proxy add-on"
  type        = string
  default     = null
}

variable "enable_ebs_csi_driver" {
  description = "Enable EBS CSI driver for persistent volumes"
  type        = bool
  default     = true
}

variable "ebs_csi_driver_addon_version" {
  description = "Version of EBS CSI driver add-on"
  type        = string
  default     = null
}
