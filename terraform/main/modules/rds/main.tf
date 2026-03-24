resource "aws_db_instance" "this" {
  identifier                 = var.db_identifier_suffix != "" ? "${lower(var.project_name)}-mariadb-${var.db_identifier_suffix}" : "${lower(var.project_name)}-mariadb"
  engine                     = "mariadb"
  engine_version             = "10.11.15"
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
  db_subnet_group_name       = var.db_subnet_group_name
  parameter_group_name       = var.db_parameter_group_name
  vpc_security_group_ids     = [var.db_security_group_id]
  auto_minor_version_upgrade = false

  tags = {
    Name = var.db_identifier_suffix != "" ? "${var.project_name}-MariaDB-${upper(var.db_identifier_suffix)}" : "${var.project_name}-MariaDB"
  }
}
