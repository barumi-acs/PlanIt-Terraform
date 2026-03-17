# ECS Instance Security Group
resource "aws_security_group" "vec_prd_ecs_pub_2a_sg" {
  name        = "VEC-PRD-ECS-PUB-2A-SG"
  description = "Security group for ECS instance in public subnet 2a"
  vpc_id      = aws_vpc.vec_prd_vpc.id # 직접 참조

  tags = {
    Name = "VEC-PRD-ECS-PUB-2A-SG"
  }

  # SSH - 관리용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  # HTTP - 컨테이너 서비스용
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for containers"
  }

  # HTTPS - 컨테이너 서비스용
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS for containers"
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}
