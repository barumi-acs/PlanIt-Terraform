resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.project_name}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.project_name}-Redis-Subnet-Group"
  }
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id       = lower("${var.project_name}-redis")
  description                = "Redis cluster for ${var.project_name}"
  engine                     = "redis"
  engine_version             = var.redis_engine_version
  node_type                  = var.redis_node_type
  num_cache_clusters         = var.redis_num_cache_nodes
  parameter_group_name       = var.redis_parameter_group_name
  port                       = 6379
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids         = [var.redis_security_group_id]
  automatic_failover_enabled = var.redis_num_cache_nodes > 1 ? true : false
  multi_az_enabled           = var.redis_num_cache_nodes > 1 ? true : false

  # 스냅샷 설정
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  # 유지보수 윈도우
  maintenance_window = var.maintenance_window

  # 암호화 설정
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # User Service가 TLS 미지원 시 false

  # 자동 백업
  auto_minor_version_upgrade = true

  tags = {
    Name = "${var.project_name}-Redis-Cluster"
  }
}
