variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_2a_cidr" {
  type = string
}

variable "public_subnet_2c_cidr" {
  type = string
}

variable "eks_private_subnet_2a_cidr" {
  type = string
}

variable "eks_private_subnet_2c_cidr" {
  type = string
}

variable "db_private_subnet_2a_cidr" {
  type = string
}

variable "db_private_subnet_2c_cidr" {
  type = string
}

variable "az_2a" {
  type = string
}

variable "az_2c" {
  type = string
}
