# ============================================
# EKS Cluster - 뇌 (Control Plane)
# ============================================
# EKS 클러스터의 Control Plane 설정 (버전, 로그, 네트워크 등)

resource "aws_eks_cluster" "main" {
  count = var.create_eks_cluster ? 1 : 0

  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster[0].arn
  version  = var.cluster_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
    security_group_ids      = [aws_security_group.eks_cluster[0].id]
  }

  enabled_cluster_log_types = var.enabled_log_types

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller,
  ]
}

# ============================================
# EKS Cluster Security Group
# ============================================

resource "aws_security_group" "eks_cluster" {
  count = var.create_eks_cluster ? 1 : 0

  name        = "${var.cluster_name}-cluster-sg"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-Cluster-SG"
    }
  )
}

# Allow inbound traffic from node group
resource "aws_security_group_rule" "eks_cluster_ingress_node" {
  count = var.create_eks_cluster ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_node_group[0].id
  security_group_id        = aws_security_group.eks_cluster[0].id
  description              = "Allow nodes to communicate with cluster API"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "eks_cluster_egress" {
  count = var.create_eks_cluster ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_cluster[0].id
  description       = "Allow all outbound traffic"
}

# ============================================
# EKS Cluster Add-ons
# ============================================

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  count = var.create_eks_cluster && var.enable_vpc_cni_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "vpc-cni"
  addon_version            = var.vpc_cni_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  count = var.create_eks_cluster && var.enable_coredns_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "coredns"
  addon_version            = var.coredns_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags

  depends_on = [aws_eks_node_group.main]
}

# Kube-proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  count = var.create_eks_cluster && var.enable_kube_proxy_addon ? 1 : 0

  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "kube-proxy"
  addon_version            = var.kube_proxy_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}

# EBS CSI Driver Add-on (for persistent volumes)
resource "aws_eks_addon" "ebs_csi_driver" {
  count = var.create_eks_cluster && var.enable_ebs_csi_driver ? 1 : 0

  cluster_name             = aws_eks_cluster.main[0].name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = var.ebs_csi_driver_addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = var.tags
}
