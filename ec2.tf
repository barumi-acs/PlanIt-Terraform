# ============================================
# EC2 Instances
# ============================================

# Bastion/ECS Instance
resource "aws_instance" "bastion" {
  count = var.create_bastion_instance ? 1 : 0

  ami                         = var.bastion_ami
  instance_type               = var.bastion_instance_type
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = module.subnets.public_subnet_ids[0]
  key_name                    = var.ec2_key_name
  associate_public_ip_address = true
  private_ip                  = var.bastion_private_ip != "" ? var.bastion_private_ip : null

  root_block_device {
    volume_size = var.bastion_volume_size
    volume_type = "gp2"
    tags = merge(
      var.common_tags,
      {
        Name = "${var.project_name}-${upper(var.environment)}-Bastion-Volume"
      }
    )
  }

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${upper(var.environment)}-Bastion"
    }
  )
}
