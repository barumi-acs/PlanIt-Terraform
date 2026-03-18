resource "aws_key_pair" "this" {
  key_name   = "PI-DEV-KEY"
  public_key = file("/Users/hambining/.ssh/PI-DEV-KEY.pub")
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = var.vpc_name
  vpc_cidr = var.vpc_cidr
  igw_name = var.igw_name

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "nat" {
  source = "../../modules/nat"

  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_ids[0]
  nat_name         = "PI-DEV-NAT-2A"
}

module "route_table" {
  source = "../../modules/route-table"

  vpc_id = module.vpc.vpc_id
  igw_id = module.vpc.internet_gateway_id
  nat_gateway_id = module.nat.nat_gateway_id

  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
}

module "eks_sg" {
  source = "../../modules/eks-sg"

  vpc_id          = module.vpc.vpc_id
  vpc_cidr        = var.vpc_cidr
  cluster_sg_name = "PI-DEV-Cluster-PRI-SG"
  node_sg_name    = "PI-DEV-Node-PRI-SG"
}

module "eks_iam" {

  source = "../../modules/eks-iam"

  cluster_name = "planit-dev-eks"
}

module "eks_cluster" {

  source = "../../modules/eks-cluster"

  cluster_name = "planit-dev-eks"

  cluster_role_arn = module.eks_iam.eks_cluster_role_arn

  subnet_ids = module.vpc.private_subnet_ids

  cluster_security_group_id = module.eks_sg.cluster_sg_id
}

module "eks_nodegroup" {

  source = "../../modules/eks-nodegroup"

  cluster_name = module.eks_cluster.cluster_name

  subnet_ids = module.vpc.private_subnet_ids
}

module "ecr_user" {
  source          = "../../modules/ecr"
  repository_name = "planit-user"
  environment     = "dev"
}

module "ecr_strategy" {
  source          = "../../modules/ecr"
  repository_name = "planit-strategy"
  environment     = "dev"
}

module "ecr_schedule" {
  source          = "../../modules/ecr"
  repository_name = "planit-schedule"
  environment     = "dev"
}

module "ecr_insight" {
  source          = "../../modules/ecr"
  repository_name = "planit-insight"
  environment     = "dev"
}

module "ecr_insightai" {
  source          = "../../modules/ecr"
  repository_name = "planit-insight-ai"
  environment     = "dev"
}

module "rds" {
  source = "../../modules/rds"

  environment        = "dev"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  eks_node_sg_id = module.eks_cluster.cluster_security_group_id
  bastion_sg_id = module.bastion.security_group_id

  db_identifier      = "planit-dev-rds"
  db_name            = "planit_user_db"
  db_username        = var.db_username
  db_password        = var.db_password

  db_instance_class  = "db.t3.small"
  allocated_storage  = 20
}

module "bastion" {
  source = "../../modules/ec2"

  name        = "PI-DEV-Bastion-PUB"
  environment = "dev"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  ami_id        = var.ec2_ami_id
  instance_type = "t3.micro"
  key_name      = aws_key_pair.this.key_name

  associate_public_ip = true

  ingress_rules = [
    {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr      = var.my_ip_cidr
    }
  ]
}

module "elasticache" {
  source = "../../modules/elasticache"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}

# module "route53" {
#   source      = "../../modules/route53"
#   domain_name = var.domain_name
#   alb_dns_name = var.alb_dns_name
#   alb_zone_id  = var.alb_zone_id
# }
#
# module "acm" {
#   source      = "../../modules/acm"
#   domain_name = var.domain_name
#   zone_id     = module.route53.zone_id
# }