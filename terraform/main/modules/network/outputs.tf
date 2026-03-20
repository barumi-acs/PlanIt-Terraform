output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_2a_id" {
  value = aws_subnet.public_2a.id
}

output "public_subnet_2c_id" {
  value = aws_subnet.public_2c.id
}

output "eks_private_subnet_2a_id" {
  value = aws_subnet.eks_private_2a.id
}

output "eks_private_subnet_2c_id" {
  value = aws_subnet.eks_private_2c.id
}

output "db_private_subnet_2a_id" {
  value = aws_subnet.db_private_2a.id
}

output "db_private_subnet_2c_id" {
  value = aws_subnet.db_private_2c.id
}

output "private_route_table_id" {
  description = "Private Route Table ID (EKS Private Subnets)"
  value       = aws_route_table.private.id
}

output "db_private_route_table_id" {
  description = "DB Private Route Table ID"
  value       = aws_route_table.db_private.id
}
