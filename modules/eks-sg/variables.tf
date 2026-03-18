variable "vpc_id" {
  description = "Security Group이 생성될 VPC ID"
  type        = string
}

variable "cluster_sg_name" {
  description = "EKS Cluster Security Group 이름"
  type        = string
}

variable "node_sg_name" {
  description = "EKS Node Security Group 이름"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR 대역"
  type        = string
}