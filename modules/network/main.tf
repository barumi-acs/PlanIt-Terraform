resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-VPC"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-IGW"
  }
}

resource "aws_subnet" "public_2a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_2a_cidr
  availability_zone       = var.az_2a
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-PUB-2A"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "public_2c" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_2c_cidr
  availability_zone       = var.az_2c
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.project_name}-PUB-2C"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "eks_private_2a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.eks_private_subnet_2a_cidr
  availability_zone = var.az_2a

  tags = {
    Name                                        = "${var.project_name}-PRI-2A"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "eks_private_2c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.eks_private_subnet_2c_cidr
  availability_zone = var.az_2c

  tags = {
    Name                                        = "${var.project_name}-PRI-2C"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "db_private_2a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_private_subnet_2a_cidr
  availability_zone = var.az_2a

  tags = {
    Name = "${var.project_name}-DB-PRI-2A"
  }
}

resource "aws_subnet" "db_private_2c" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_private_subnet_2c_cidr
  availability_zone = var.az_2c

  tags = {
    Name = "${var.project_name}-DB-PRI-2C"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-NAT-EIP-2A"
  }
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_2a.id

  tags = {
    Name = "${var.project_name}-NAT-2A"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-PUB-RT"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-PRI-RT"
  }
}

resource "aws_route_table" "db_private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-DB-PRI-RT"
  }
}

resource "aws_route_table_association" "public_2a" {
  subnet_id      = aws_subnet.public_2a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2c" {
  subnet_id      = aws_subnet.public_2c.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "eks_private_2a" {
  subnet_id      = aws_subnet.eks_private_2a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "eks_private_2c" {
  subnet_id      = aws_subnet.eks_private_2c.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_private_2a" {
  subnet_id      = aws_subnet.db_private_2a.id
  route_table_id = aws_route_table.db_private.id
}

resource "aws_route_table_association" "db_private_2c" {
  subnet_id      = aws_subnet.db_private_2c.id
  route_table_id = aws_route_table.db_private.id
}
