variable "vpc_name" {
  description = "VPC 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
}

variable "public_subnets" {
  description = "Public subnet 정보"
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}

variable "private_subnets" {
  description = "Private subnet 정보"
  type = list(object({
    name              = string
    cidr              = string
    availability_zone = string
  }))
}

variable "igw_name" {
  description = "Internet Gateway 이름"
  type        = string
}