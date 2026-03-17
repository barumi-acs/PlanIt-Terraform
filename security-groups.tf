# ============================================
# Security Groups
# ============================================

# Bastion/ECS Instance Security Group
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-${upper(var.environment)}-Bastion-SG"
  description = "Security group for Bastion/ECS instance in public subnet"
  vpc_id      = module.vpc.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${upper(var.environment)}-Bastion-SG"
    }
  )
}

# SSH Access
resource "aws_security_group_rule" "bastion_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "SSH access"
  security_group_id = aws_security_group.bastion.id
}

# HTTP Access
resource "aws_security_group_rule" "bastion_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTP for containers"
  security_group_id = aws_security_group.bastion.id
}

# HTTPS Access
resource "aws_security_group_rule" "bastion_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "HTTPS for containers"
  security_group_id = aws_security_group.bastion.id
}

# All Outbound Traffic
resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "Allow all outbound traffic"
  security_group_id = aws_security_group.bastion.id
}
