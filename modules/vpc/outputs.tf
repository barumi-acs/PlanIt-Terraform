output "vpc_id" {
  description = "생성된 VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "생성된 public subnet ID 목록"
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "생성된 private subnet ID 목록"
  value       = values(aws_subnet.private)[*].id
}

output "internet_gateway_id" {
  description = "생성된 IGW ID"
  value       = aws_internet_gateway.this.id
}