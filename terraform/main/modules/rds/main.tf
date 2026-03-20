resource "aws_db_subnet_group" "this" {
  name       = "${lower(var.project_name)}-db-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = {
    Name = "${var.project_name}-DB-GROUP"
  }
}

resource "aws_db_parameter_group" "this" {
  name        = "${lower(var.project_name)}-mariadb-params"
  family      = "mariadb${join(".", slice(split(".", var.db_engine_version), 0, 2))}"
  description = "Custom parameter group for ${var.project_name} MariaDB"

  parameter {
    name         = "max_connections"
    value        = "1000"
    apply_method = "immediate"
  }

  # UTF-8 문자셋 설정 (한글 지원)
  parameter {
    name         = "character_set_server"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_client"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_connection"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_database"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "character_set_results"
    value        = "utf8mb4"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_server"
    value        = "utf8mb4_unicode_ci"
    apply_method = "immediate"
  }

  parameter {
    name         = "collation_connection"
    value        = "utf8mb4_unicode_ci"
    apply_method = "immediate"
  }

  # 타임존 설정 (Asia/Seoul)
  parameter {
    name         = "time_zone"
    value        = "Asia/Seoul"
    apply_method = "immediate"
  }

  tags = {
    Name = "${var.project_name}-MariaDB-Params"
  }
}

resource "aws_db_instance" "this" {
  identifier                 = var.db_identifier_suffix != "" ? "${lower(var.project_name)}-mariadb-${var.db_identifier_suffix}" : "${lower(var.project_name)}-mariadb"
  engine                     = "mariadb"
  engine_version             = var.db_engine_version
  instance_class             = var.db_instance_class
  allocated_storage          = 20
  max_allocated_storage      = 100
  storage_type               = "gp3"
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = var.db_password
  port                       = 3306
  multi_az                   = true
  publicly_accessible        = false
  storage_encrypted          = true
  backup_retention_period    = 30    # 7 → 30일 (프로덕션 권장)
  skip_final_snapshot        = false # true → false (프로덕션 필수)
  final_snapshot_identifier  = "${lower(var.project_name)}-mariadb-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  deletion_protection        = false # 삭제 보호 해제 (destroy 가능)
  db_subnet_group_name       = aws_db_subnet_group.this.name
  parameter_group_name       = aws_db_parameter_group.this.name
  vpc_security_group_ids     = [var.db_security_group_id]
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-MariaDB"
  }
}
