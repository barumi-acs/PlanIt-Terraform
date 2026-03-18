resource "aws_security_group" "rds" {
  name        = "planit-${var.environment}-rds-sg"
  description = "Security group for PlanIt RDS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MariaDB from EKS nodes"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.eks_node_sg_id]
  }

  ingress {
    description = "Allow MariaDB from Bastion server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "planit-${var.environment}-rds-sg"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "planit-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "planit-${var.environment}-db-subnet-group"
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.db_identifier
  engine                 = "mariadb"
  engine_version         = var.engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.allocated_storage

  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  multi_az               = false
  storage_encrypted      = true

  backup_retention_period = 0

  tags = {
    Name = var.db_identifier
  }
}