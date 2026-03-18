output "bastion_public_ip" {
  value = module.bastion.public_ip
}

output "bastion_sg_id" {
  value = module.bastion.security_group_id
}

output "redis_endpoint" {
  value = module.elasticache.redis_endpoint
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}