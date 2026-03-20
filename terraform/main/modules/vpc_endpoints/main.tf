# ============================================
# DynamoDB VPC Endpoint (Gateway Type)
# ============================================
# Gateway Endpoint는 무료이며, Route Table에 자동으로 라우팅 규칙을 추가합니다.
# EKS Pod에서 DynamoDB 접근 시 Public Internet을 거치지 않고 VPC 내부 통신으로 처리됩니다.

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"

  # EKS Private Subnet의 Route Table에 자동으로 DynamoDB 라우팅 규칙 추가
  route_table_ids = var.route_table_ids

  # VPC Endpoint Policy: 특정 DynamoDB 테이블에만 접근 허용
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowDynamoDBAccess"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:DescribeTable"
        ]
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_table_name}/index/*"
        ]
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-DynamoDB-VPC-Endpoint"
    Environment = var.environment
  }
}
