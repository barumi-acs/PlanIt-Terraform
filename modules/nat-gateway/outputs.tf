output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.this.id
}

output "nat_gateway_public_ip" {
  description = "The public IP address of the NAT Gateway"
  value       = aws_eip.this.public_ip
}

output "elastic_ip_id" {
  description = "The ID of the Elastic IP"
  value       = aws_eip.this.id
}
