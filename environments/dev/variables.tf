variable "vpc_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "igw_name" {
  type = string
}

variable "public_subnets" {
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "my_ip_cidr" {
  description = "My public IP in CIDR format"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "ec2_ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}
#
# variable "domain_name" {
#   description = "Root domain name"
#   type        = string
# }
#
# variable "alb_dns_name" {
#   description = "ALB DNS name"
#   type        = string
# }
#
# variable "alb_zone_id" {
#   description = "ALB Hosted Zone ID"
#   type        = string
# }