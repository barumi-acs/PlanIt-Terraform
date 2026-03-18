resource "aws_eks_cluster" "this" {

  name = var.cluster_name

  role_arn = var.cluster_role_arn

  version = "1.29"

  vpc_config {

    subnet_ids = var.subnet_ids

    security_group_ids = [
      var.cluster_security_group_id
    ]

    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    var.cluster_role_arn
  ]
}