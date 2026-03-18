vpc_name = "PI-DEV-VPC"
vpc_cidr = "10.230.0.0/16"
igw_name = "PI-DEV-IGW"

private_subnets = [
  {
    name              = "PI-DEV-PRI-2A"
    cidr              = "10.230.1.0/24"
    availability_zone = "ap-northeast-2a"
  },
  {
    name              = "PI-DEV-PRI-2C"
    cidr              = "10.230.2.0/24"
    availability_zone = "ap-northeast-2c"
  }
]

public_subnets = [
  {
    name              = "PI-DEV-PUB-2A"
    cidr              = "10.230.4.0/24"
    availability_zone = "ap-northeast-2a"
  },
  {
    name              = "PI-DEV-PUB-2C"
    cidr              = "10.230.5.0/24"
    availability_zone = "ap-northeast-2c"
  }
]

db_username = "root"
db_password = "rootroot"

ec2_ami_id = "ami-0c9c942bd7bf113a2"
key_name   = "PI-DEV-KEY"
my_ip_cidr = "0.0.0.0/0"
#
# domain_name = "hambining.shop"
#
# alb_dns_name = "k8s-planitde-planitin-dfe5962207-54401318.ap-northeast-2.elb.amazonaws.com"
# alb_zone_id  = "ZWKZPGTI48KDX"