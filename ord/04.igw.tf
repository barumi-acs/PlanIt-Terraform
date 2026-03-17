resource "aws_internet_gateway" "pi_dev_igw" {
  vpc_id = aws_vpc.pi_dev_vpc.id
  tags = {
    "Name" = "PI-DEV-IGW"
  }
}
