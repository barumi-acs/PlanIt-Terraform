variable "project_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = null
}

variable "admin_cidr" {
  type = string
}
