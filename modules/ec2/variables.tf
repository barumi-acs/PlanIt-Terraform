variable "name" {
  description = "EC2 logical name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID where EC2 will be launched"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP"
  type        = bool
  default     = false
}

variable "ingress_rules" {
  description = "Ingress rules for the security group"
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
    cidr      = string
  }))
  default = []
}