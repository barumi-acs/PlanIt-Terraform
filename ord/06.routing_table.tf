# 라우팅 테이블
resource "aws_route_table" "pi_dev_pub_rt" {
  vpc_id = aws_vpc.pi_dev_vpc.id

  tags = {
    "Name" = "PI-DEV-PUB-RT"
  }
}

resource "aws_route_table" "pi_dev_pri_rt" {
  vpc_id = aws_vpc.pi_dev_vpc.id

  tags = {
    "Name" = "PI-DEV-PRI-RT"
  }
}

# 라우팅
resource "aws_route" "pi_dev_pub_route" {
  route_table_id         = aws_route_table.pi_dev_pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.pi_dev_igw.id
}

resource "aws_route" "pi_dev_pri_route" {
  route_table_id         = aws_route_table.pi_dev_pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.pi_dev_igw.id
}

# 명시적 서브넷 연결
# 1. Bastion (Public) 서브넷 -> Public RT 연결
resource "aws_route_table_association" "pi_dev_bst_pub_assoc" {
  subnet_id      = aws_subnet.pi_dev_bastion_pub_2a.id
  route_table_id = aws_route_table.pi_dev_pub_rt.id
}

# 2. Private 2A 서브넷 -> Private RT 연결 (중요!)
resource "aws_route_table_association" "pi_dev_pri_2a_assoc" {
  subnet_id      = aws_subnet.pi_dev_pri_2a.id
  route_table_id = aws_route_table.pi_dev_pri_rt.id
}

# 3. Private 2C 서브넷 -> Private RT 연결
resource "aws_route_table_association" "pi_dev_pri_2c_assoc" {
  subnet_id      = aws_subnet.pi_dev_pri_2c.id
  route_table_id = aws_route_table.pi_dev_pri_rt.id
}