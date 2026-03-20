variable "project_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type = string
}

variable "db_engine_version" {
  type = string
}

variable "db_subnet_ids" {
  type = list(string)
}

variable "db_security_group_id" {
  type = string
}

variable "db_identifier_suffix" {
  description = "RDS 인스턴스 식별자 접미사 (예: user, schedule, strategy, insight)"
  type        = string
  default     = ""
}

variable "db_subnet_group_name" {
  description = "기존에 생성된 DB Subnet Group 이름"
  type        = string
}

variable "db_parameter_group_name" {
  description = "기존에 생성된 DB Parameter Group 이름"
  type        = string
}
