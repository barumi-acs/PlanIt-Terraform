# ============================================
# EKS Module Variables
# ============================================
# 외부(Root 모듈)에서 받아올 값들

# ============================================
# General Configuration
# ============================================

variable "create_eks_cluster" {
  description = "Whether to create EKS cluster"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================
# Network Configuration
# ============================================

variable "vpc_id" {
  description = "VPC ID where EKS cluster will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EKS nodes"
  type        = list(string)
}

# ============================================
# EKS Cluster Configuration
# ============================================

variable "cluster_version" {
  description = "Kubernetes version for EKS cluster"
  type        = string
  default     = "1.28"
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "List of CIDR blocks that can access the public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enabled_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "enable_cloudwatch_logs" {
  description = "Enable CloudWatch logs for EKS nodes"
  type        = bool
  default     = true
}

# ============================================
# EKS Node Group Configuration
# ============================================

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 6
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_unavailable" {
  description = "Maximum number of nodes unavailable during update"
  type        = number
  default     = 1
}

variable "node_instance_types" {
  description = "List of instance types for EKS nodes"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Type of capacity (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_disk_size" {
  description = "Disk size in GB for EKS nodes"
  type        = number
  default     = 20
}

variable "node_ssh_key" {
  description = "EC2 key pair name for SSH access to nodes"
  type        = string
  default     = ""
}

variable "node_ssh_source_sg_ids" {
  description = "Security group IDs allowed to SSH to nodes"
  type        = list(string)
  default     = []
}

variable "node_labels" {
  description = "Key-value map of Kubernetes labels for nodes"
  type        = map(string)
  default     = {}
}

variable "node_taints" {
  description = "List of Kubernetes taints to apply to nodes"
  type = list(object({
    key    = string
    value  = string
    effect = string
  }))
  default = []
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
