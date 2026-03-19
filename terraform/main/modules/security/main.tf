resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-Bastion-PUB-SG"
  description = "Bastion public security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-Bastion-PUB-SG"
  }
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-ALB-SG"
  description = "ALB security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-ALB-SG"
  }
}

resource "aws_security_group" "node" {
  name        = "${var.project_name}-Node-PRI-SG"
  description = "EKS node private security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-Node-PRI-SG"
  }
}

resource "aws_security_group" "cluster" {
  name        = "${var.project_name}-Cluster-PRI-SG"
  description = "EKS cluster private security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-Cluster-PRI-SG"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-DB-PRI-SG"
  description = "RDS private security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-DB-PRI-SG"
  }
}

resource "aws_security_group" "redis" {
  name        = "${var.project_name}-Redis-PRI-SG"
  description = "Redis private security group"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-Redis-PRI-SG"
  }
}

resource "aws_vpc_security_group_egress_rule" "bastion_all_out" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb_tcp_out_to_node" {
  security_group_id            = aws_security_group.alb.id
  ip_protocol                  = "tcp"
  from_port                    = 0
  to_port                      = 65535
  referenced_security_group_id = aws_security_group.node.id
}

resource "aws_vpc_security_group_egress_rule" "node_all_out" {
  security_group_id = aws_security_group.node.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "cluster_kubelet_to_node" {
  security_group_id            = aws_security_group.cluster.id
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
  referenced_security_group_id = aws_security_group.node.id
}

resource "aws_vpc_security_group_egress_rule" "db_all_out" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "redis_all_out" {
  security_group_id = aws_security_group.redis.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "bastion_ssh_in" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = var.admin_cidr
}

resource "aws_vpc_security_group_ingress_rule" "bastion_https_from_vpc" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "bastion_icmp_from_vpc" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "alb_http_in" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https_in" {
  security_group_id = aws_security_group.alb.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "node_nodeport_from_alb" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 30000
  to_port                      = 32767
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_ingress_rule" "node_443_from_bastion" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "node_ssh_from_cluster" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
  referenced_security_group_id = aws_security_group.cluster.id
}

resource "aws_vpc_security_group_ingress_rule" "node_kubelet_from_cluster" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 10250
  to_port                      = 10250
  referenced_security_group_id = aws_security_group.cluster.id
}

resource "aws_vpc_security_group_ingress_rule" "node_icmp_from_vpc" {
  security_group_id = aws_security_group.node.id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "cluster_https_from_vpc" {
  security_group_id = aws_security_group.cluster.id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "cluster_https_from_bastion" {
  security_group_id            = aws_security_group.cluster.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "cluster_icmp_from_vpc" {
  security_group_id = aws_security_group.cluster.id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql_from_node" {
  security_group_id            = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.node.id
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql_from_bastion" {
  security_group_id            = aws_security_group.db.id
  ip_protocol                  = "tcp"
  from_port                    = 3306
  to_port                      = 3306
  referenced_security_group_id = aws_security_group.bastion.id
}

resource "aws_vpc_security_group_ingress_rule" "db_icmp_from_vpc" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "node_self_in" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "-1" # 모든 프로토콜(TCP/UDP/ICMP 등) 
  from_port                    = -1
  to_port                      = -1
  referenced_security_group_id = aws_security_group.node.id # 자기 자신(Node SG) 지정
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql_from_vpc" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "tcp"
  from_port         = 3306
  to_port           = 3306
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}

resource "aws_vpc_security_group_ingress_rule" "node_webhook_from_cluster" {
  security_group_id            = aws_security_group.node.id
  ip_protocol                  = "tcp"
  from_port                    = 9443
  to_port                      = 9443
  referenced_security_group_id = aws_security_group.cluster.id
}

# Node → Redis 접근 허용 (6379 포트)
resource "aws_vpc_security_group_ingress_rule" "redis_from_node" {
  security_group_id            = aws_security_group.redis.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_security_group.node.id
}

# Bastion → Redis 접근 허용 (관리 목적)
resource "aws_vpc_security_group_ingress_rule" "redis_from_bastion" {
  security_group_id            = aws_security_group.redis.id
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
  referenced_security_group_id = aws_security_group.bastion.id
}

# Redis ICMP from VPC
resource "aws_vpc_security_group_ingress_rule" "redis_icmp_from_vpc" {
  security_group_id = aws_security_group.redis.id
  ip_protocol       = "icmp"
  from_port         = -1
  to_port           = -1
  cidr_ipv4         = data.aws_vpc.selected.cidr_block
}
