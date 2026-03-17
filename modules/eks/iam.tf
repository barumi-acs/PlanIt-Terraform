# ============================================
# IAM Roles for EKS - 통행증 (권한)
# ============================================
# EKS 클러스터와 노드가 AWS 서비스를 이용할 수 있게 해주는 권한 설정

# ============================================
# EKS Cluster Role
# ============================================

resource "aws_iam_role" "eks_cluster" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-Cluster-Role"
    }
  )
}

# Attach required policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  count = var.create_eks_cluster ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster[0].name
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  count = var.create_eks_cluster ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster[0].name
}

# ============================================
# IAM Role for EKS Node Group
# ============================================

resource "aws_iam_role" "eks_node_group" {
  count = var.create_eks_cluster ? 1 : 0

  name = "${var.cluster_name}-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-NodeGroup-Role"
    }
  )
}

# Attach required policies to Node Group Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  count = var.create_eks_cluster ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_group[0].name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  count = var.create_eks_cluster ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_group[0].name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  count = var.create_eks_cluster ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_group[0].name
}

# Additional policy for CloudWatch Logs (optional but recommended)
resource "aws_iam_role_policy_attachment" "eks_cloudwatch_policy" {
  count = var.create_eks_cluster && var.enable_cloudwatch_logs ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.eks_node_group[0].name
}

# ============================================
# IAM Policy for EBS CSI Driver (for persistent volumes)
# ============================================

resource "aws_iam_role_policy_attachment" "eks_ebs_csi_policy" {
  count = var.create_eks_cluster && var.enable_ebs_csi_driver ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.eks_node_group[0].name
}
