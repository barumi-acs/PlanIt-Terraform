output "cluster_sg_id" {
  description = "EKS Cluster Security Group ID"
  value       = aws_security_group.cluster.id
}

output "node_sg_id" {
  description = "EKS Node Security Group ID"
  value       = aws_security_group.node.id
}