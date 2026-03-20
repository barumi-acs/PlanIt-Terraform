output "dynamodb_vpc_endpoint_id" {
  description = "DynamoDB VPC Endpoint ID"
  value       = aws_vpc_endpoint.dynamodb.id
}

output "dynamodb_vpc_endpoint_prefix_list_id" {
  description = "DynamoDB VPC Endpoint Prefix List ID (Security Group에서 사용 가능)"
  value       = aws_vpc_endpoint.dynamodb.prefix_list_id
}

output "dynamodb_vpc_endpoint_state" {
  description = "DynamoDB VPC Endpoint State"
  value       = aws_vpc_endpoint.dynamodb.state
}
