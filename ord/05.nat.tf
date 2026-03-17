# 탄력적 IP
resource "aws_eip" "pi_dev_nat_eip" {
  domain = "vpc"
  tags = {
    "Name" = "PI-DEV-NAT-EIP"
  }
}

# NAT 게이트웨이
resource "aws_nat_gateway" "pi_dev_nat_2a" {
  allocation_id = aws_eip.pi_dev_nat_eip.id
  subnet_id     = aws_subnet.pi_dev_bastion_pub_2a.id
  tags = {
    "Name" = "PI-DEV-NAT-2A"
  }
}
