# ============================================
# NAT Gateway Module
# Creates NAT Gateway with Elastic IP
# ============================================

resource "aws_eip" "this" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-NAT-EIP"
    }
  )

  depends_on = [var.internet_gateway_id]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = var.subnet_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-NAT-2A"
    }
  )

  depends_on = [var.internet_gateway_id]
}
