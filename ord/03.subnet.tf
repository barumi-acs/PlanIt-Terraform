# Public Subnet
resource "aws_subnet" "pi_dev_bastion_pub_2a" {
  vpc_id                  = aws_vpc.pi_dev_vpc.id
  cidr_block              = "10.230.4.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  tags = {
    "Name"                                        = "PI-DEV-Bastion-PUB-2A"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/terraform-eks-cluster" = "shared"
  }
}


# Private Subnet
resource "aws_subnet" "pi_dev_pri_2a" {
  vpc_id                  = aws_vpc.pi_dev_vpc.id
  cidr_block              = "10.230.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = false
  tags = {
    "Name"                                        = "PI-DEV-PRI-2A"
    "kubernetes.io/role/elb"                      = "1"
    "kubernetes.io/cluster/terraform-eks-cluster" = "shared"
  }
}

resource "aws_subnet" "pi_dev_pri_2c" {
  vpc_id            = aws_vpc.pi_dev_vpc.id
  cidr_block        = "10.230.2.0/24"
  availability_zone = "ap-northeast-2c"
  tags = {
    "Name"                                        = "PI-DEV-PRI-2C"
    "kubernetes.io/role/internal-elb"             = "1"
    "kubernetes.io/cluster/terraform-eks-cluster" = "shared"
  }
}