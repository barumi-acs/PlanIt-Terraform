# ============================================
# EKS Node Groups - 일꾼들 (Worker Nodes)
# ============================================
# 실제 컨테이너가 실행되는 Worker Node 설정 (인스턴스 타입, 개수 등)
# 5개 마이크로서비스를 위한 노드 그룹: User-svc, Schedule-svc, Strategy-svc, Insight-svc, InsightAI-svc

# ============================================
# EKS Node Group Security Group
# ============================================

resource "aws_security_group" "eks_node_group" {
  count = var.create_eks_cluster ? 1 : 0

  name        = "${var.cluster_name}-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name                                        = "${var.cluster_name}-Node-SG"
      "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    }
  )
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "node_ingress_self" {
  count = var.create_eks_cluster ? 1 : 0

  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.eks_node_group[0].id
  description       = "Allow nodes to communicate with each other"
}

# Allow nodes to receive communication from cluster control plane
resource "aws_security_group_rule" "node_ingress_cluster" {
  count = var.create_eks_cluster ? 1 : 0

  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster[0].id
  security_group_id        = aws_security_group.eks_node_group[0].id
  description              = "Allow worker Kubelets and pods to receive communication from cluster control plane"
}

# Allow pods to communicate with cluster API
resource "aws_security_group_rule" "node_ingress_cluster_https" {
  count = var.create_eks_cluster ? 1 : 0

  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.eks_cluster[0].id
  security_group_id        = aws_security_group.eks_node_group[0].id
  description              = "Allow pods to communicate with cluster API"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "node_egress" {
  count = var.create_eks_cluster ? 1 : 0

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_node_group[0].id
  description       = "Allow all outbound traffic"
}

# ============================================
# EKS Managed Node Group
# Deployed in Private Subnets for 5 microservices
# ============================================

resource "aws_eks_node_group" "main" {
  count = var.create_eks_cluster ? 1 : 0

  cluster_name    = aws_eks_cluster.main[0].name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node_group[0].arn
  subnet_ids      = var.private_subnet_ids

  # Scaling configuration for 5 microservices
  # User-svc, Schedule-svc, Strategy-svc, Insight-svc, InsightAI-svc
  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  # Update configuration
  update_config {
    max_unavailable = var.node_max_unavailable
  }

  # Instance types
  instance_types = var.node_instance_types
  capacity_type  = var.node_capacity_type
  disk_size      = var.node_disk_size

  # Remote access (optional - for debugging)
  dynamic "remote_access" {
    for_each = var.node_ssh_key != "" ? [1] : []
    content {
      ec2_ssh_key               = var.node_ssh_key
      source_security_group_ids = var.node_ssh_source_sg_ids
    }
  }

  # Labels for pod scheduling
  labels = merge(
    {
      Environment = var.environment
      NodeGroup   = "main"
    },
    var.node_labels
  )

  # Taints (optional - for dedicated workloads)
  dynamic "taint" {
    for_each = var.node_taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-NodeGroup"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  # Ensure nodes are replaced before destroying
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}
