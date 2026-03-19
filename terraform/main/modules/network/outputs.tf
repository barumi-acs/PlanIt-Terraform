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
