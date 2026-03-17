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

  tags = {
    Name = "${var.project_name}-MariaDB-Params"
  }
}

resource "aws_db_instance" "this" {
  identifier                 = "${lower(var.project_name)}-mariadb"
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
  backup_retention_period    = 7
  skip_final_snapshot        = true
  deletion_protection        = false
  db_subnet_group_name       = aws_db_subnet_group.this.name
  parameter_group_name       = aws_db_parameter_group.this.name
  vpc_security_group_ids     = [var.db_security_group_id]
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-MariaDB"
  }
}
