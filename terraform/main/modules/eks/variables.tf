variable "project_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "cluster_subnet_ids" {
  type = list(string)
}

variable "node_subnet_ids" {
  type = list(string)
}

variable "cluster_security_group" {
  type = string
}

variable "node_security_group" {
  type = string
}

variable "bastion_security_group" {
  type = string
}

variable "node_instance_types" {
  type = list(string)
}

variable "node_desired_size" {
  type = number
}

variable "node_min_size" {
  type = number
}

variable "node_max_size" {
  type = number
}

variable "key_name" {
  type    = string
  default = null
}

variable "bastion_role_arn" {
  type = string
}

variable "loki_bucket_arn" {
  description = "Loki S3 버킷 ARN"
  type        = string
  default     = ""
}
