# ============================================
# VPC Module
# ============================================
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "${var.project_name}-${upper(var.environment)}-VPC"
  vpc_cidr             = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = var.common_tags
}

# ============================================
# Subnets Module
# ============================================
module "subnets" {
  source = "./modules/subnets"

  vpc_id               = module.vpc.vpc_id
  name_prefix          = "${var.project_name}-${upper(var.environment)}"
  public_subnet_cidrs  = [var.public_subnet_cidr_2a, var.public_subnet_cidr_2c ]
  private_subnet_cidrs = [var.private_subnet_cidr_2a, var.private_subnet_cidr_2c]
  availability_zones   = ["${var.aws_region}a", "${var.aws_region}c"]
  eks_cluster_name     = var.eks_cluster_name

  tags = var.common_tags
}

# ============================================
# NAT Gateway Module
# ============================================
module "nat_gateway" {
  source = "./modules/nat-gateway"

  name_prefix         = "${var.project_name}-${upper(var.environment)}"
  subnet_id           = module.subnets.public_subnet_ids[0]
  internet_gateway_id = module.vpc.internet_gateway_id

  tags = var.common_tags
}

# ============================================
# Route Tables Module
# ============================================
module "route_tables" {
  source = "./modules/route-tables"

  vpc_id              = module.vpc.vpc_id
  name_prefix         = "${var.project_name}-${upper(var.environment)}"
  internet_gateway_id = module.vpc.internet_gateway_id
  nat_gateway_id      = module.nat_gateway.nat_gateway_id
  public_subnet_ids   = module.subnets.public_subnet_ids
  private_subnet_ids  = module.subnets.private_subnet_ids

  tags = var.common_tags
}

# ============================================
# EKS Module
# ============================================
module "eks" {
  source = "./modules/eks"

<<<<<<< Updated upstream
  create_eks_cluster = var.create_eks_cluster
  cluster_name       = var.eks_cluster_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.subnets.private_subnet_ids

  # Cluster Configuration
  cluster_version         = var.eks_cluster_version
  endpoint_private_access = var.eks_endpoint_private_access
  endpoint_public_access  = var.eks_endpoint_public_access
  public_access_cidrs     = var.eks_public_access_cidrs
  enabled_log_types       = var.eks_enabled_log_types
  enable_cloudwatch_logs  = var.enable_eks_cloudwatch_logs

  # Node Group Configuration
  node_desired_size      = var.eks_node_desired_size
  node_max_size          = var.eks_node_max_size
  node_min_size          = var.eks_node_min_size
  node_max_unavailable   = var.eks_node_max_unavailable
  node_instance_types    = var.eks_node_instance_types
  node_capacity_type     = var.eks_node_capacity_type
  node_disk_size         = var.eks_node_disk_size
  node_ssh_key           = var.eks_node_ssh_key
  node_ssh_source_sg_ids = var.eks_node_ssh_source_sg_ids
  node_labels            = var.eks_node_labels
  node_taints            = var.eks_node_taints

  # Add-ons Configuration
  enable_vpc_cni_addon         = var.enable_vpc_cni_addon
  vpc_cni_addon_version        = var.vpc_cni_addon_version
  enable_coredns_addon         = var.enable_coredns_addon
  coredns_addon_version        = var.coredns_addon_version
  enable_kube_proxy_addon      = var.enable_kube_proxy_addon
  kube_proxy_addon_version     = var.kube_proxy_addon_version
  enable_ebs_csi_driver        = var.enable_ebs_csi_driver
  ebs_csi_driver_addon_version = var.ebs_csi_driver_addon_version

  tags = var.common_tags
=======
  project_name           = var.project_name
  cluster_name           = var.cluster_name
  kubernetes_version     = var.kubernetes_version
  cluster_subnet_ids     = [module.network.public_subnet_2a_id, module.network.public_subnet_2c_id, module.network.eks_private_subnet_2a_id, module.network.eks_private_subnet_2c_id]
  node_subnet_ids        = [module.network.eks_private_subnet_2a_id, module.network.eks_private_subnet_2c_id]
  cluster_security_group = module.security.cluster_sg_id
  node_security_group    = module.security.node_sg_id
  bastion_security_group = module.security.bastion_sg_id
  node_instance_types    = var.node_instance_types
  node_desired_size      = var.node_desired_size
  node_min_size          = var.node_min_size
  node_max_size          = var.node_max_size
  key_name               = module.bastion.key_name
  bastion_role_arn       = module.bastion.role_arn
}

module "rds" {
  source = "./modules/rds"

  project_name         = var.project_name
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  db_instance_class    = var.db_instance_class
  db_engine_version    = var.db_engine_version
  db_subnet_ids        = [module.network.db_private_subnet_2a_id, module.network.db_private_subnet_2c_id]
  db_security_group_id = module.security.db_sg_id
}

module "s3" {
  source = "./modules/s3"

  bucket_name  = var.s3_bucket_name
  project_name = var.project_name
}

module "dynamodb" {
  source = "./modules/dynamodb"

  project_name = var.project_name
  table_name   = var.dynamodb_table_name
}

module "acm" {
  count  = var.create_acm_certificate ? 1 : 0
  source = "./modules/acm"

  project_name              = var.project_name
  domain_name               = var.external_dns_domain_filters[0]
  subject_alternative_names = length(var.external_dns_domain_filters) > 1 ? slice(var.external_dns_domain_filters, 1, length(var.external_dns_domain_filters)) : []
  create_route53_zone       = var.create_route53_zone
  route53_zone_id           = var.route53_zone_id
}

locals {
  acm_certificate_arn = var.create_acm_certificate ? module.acm[0].certificate_arn : var.acm_certificate_arn
}

module "secrets" {
  source = "./modules/secrets"

  project_name           = var.project_name
  oidc_provider_arn      = module.eks.oidc_provider_arn
  oidc_issuer            = module.eks.oidc_issuer
  db_username            = var.db_username
  db_password            = var.db_password
  aws_access_key_id      = var.aws_access_key_id
  aws_secret_access_key  = var.aws_secret_access_key
  cognito_client_secret  = var.cognito_client_secret
  jwt_secret             = var.jwt_secret
  gnews_api_key          = var.gnews_api_key
}

module "ingress" {
  source = "./modules/ingress"

  project_name          = var.project_name
  namespace             = "planit-dev"
  domain_name           = var.external_dns_domain_filters[0]
  acm_certificate_arn   = local.acm_certificate_arn
  cognito_user_pool_arn = var.cognito_user_pool_arn
  cognito_alb_client_id = var.cognito_alb_client_id
  cognito_domain        = var.cognito_domain

  depends_on = [module.eks]
}

resource "terraform_data" "init_planit_databases" {
  triggers_replace = {
    rds_endpoint = module.rds.endpoint
    rds_port     = tostring(module.rds.port)
    db_user      = var.db_username
    db_password  = var.db_password
    db_names     = join(",", var.planit_db_names)
    bastion_ip   = module.bastion.public_ip
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = module.bastion.public_ip
    private_key = file("${path.root}/${var.project_name}-key.pem")
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y mariadb105 || sudo dnf install -y mariadb",
      <<-EOT
        cat >/tmp/create_planit_dbs.sql <<'SQL'
        CREATE DATABASE IF NOT EXISTS planit_insight_db;
        CREATE DATABASE IF NOT EXISTS planit_schedule_db;
        CREATE DATABASE IF NOT EXISTS planit_strategy_db;
        CREATE DATABASE IF NOT EXISTS planit_user_db;
        SQL

        mysql -h ${module.rds.endpoint} -P ${module.rds.port} -u${var.db_username} -p'${var.db_password}' < /tmp/create_planit_dbs.sql
        rm -f /tmp/create_planit_dbs.sql
      EOT
    ]
  }

  depends_on = [
    module.rds,
    module.bastion
  ]
}

resource "terraform_data" "install_lbc" {
  triggers_replace = {
    cluster_name = module.eks.cluster_name
    lbc_role_arn = module.eks.lbc_role_arn
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = module.bastion.public_ip
    private_key = file("${path.root}/${var.project_name}-key.pem")
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}",
      "which helm 2>/dev/null || curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
      "helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true",
      "helm repo update eks",
      "printf '%s\\n' 'clusterName: ${module.eks.cluster_name}' 'serviceAccount:' '  create: true' '  name: aws-load-balancer-controller' '  annotations:' '    eks.amazonaws.com/role-arn: ${module.eks.lbc_role_arn}' 'region: ${var.aws_region}' 'vpcId: ${module.network.vpc_id}' > /tmp/lbc-values.yaml",
      "helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system -f /tmp/lbc-values.yaml --wait --timeout 5m0s",
    ]
  }

  depends_on = [module.eks, module.bastion]
}

resource "terraform_data" "install_external_dns" {
  triggers_replace = {
    cluster_name     = module.eks.cluster_name
    external_dns_arn = module.eks.external_dns_role_arn
    domain_filters   = jsonencode(var.external_dns_domain_filters)
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = module.bastion.public_ip
    private_key = file("${path.root}/${var.project_name}-key.pem")
    timeout     = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}",
      "which helm 2>/dev/null || curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
      "helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/ 2>/dev/null || true",
      "helm repo update external-dns",
      join("\n", concat(
        [
          "cat >/tmp/external-dns-values.yaml <<'YAML'",
          "provider:",
          "  name: aws",
          "policy: sync",
          "registry: txt",
          "txtOwnerId: ${module.eks.cluster_name}",
          "sources:",
          "  - service",
          "  - ingress",
          "domainFilters:",
        ],
        [for domain in var.external_dns_domain_filters : "  - ${domain}"],
        [
          "env:",
          "  - name: AWS_DEFAULT_REGION",
          "    value: ${var.aws_region}",
          "serviceAccount:",
          "  create: true",
          "  name: external-dns",
          "  annotations:",
          "    eks.amazonaws.com/role-arn: ${module.eks.external_dns_role_arn}",
          "YAML",
        ]
      )),
      "helm upgrade --install external-dns external-dns/external-dns -n kube-system -f /tmp/external-dns-values.yaml --version 1.14.3 --wait --timeout 5m0s",
    ]
  }

  depends_on = [module.eks, module.bastion, terraform_data.install_lbc]
>>>>>>> Stashed changes
}
