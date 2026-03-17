locals {
  az_2a = "${var.aws_region}a"
  az_2c = "${var.aws_region}c"
}

module "network" {
  source = "./modules/network"

  project_name               = var.project_name
  cluster_name               = var.cluster_name
  vpc_cidr                   = var.vpc_cidr
  public_subnet_2a_cidr      = var.public_subnet_2a_cidr
  public_subnet_2c_cidr      = var.public_subnet_2c_cidr
  eks_private_subnet_2a_cidr = var.eks_private_subnet_2a_cidr
  eks_private_subnet_2c_cidr = var.eks_private_subnet_2c_cidr
  db_private_subnet_2a_cidr  = var.db_private_subnet_2a_cidr
  db_private_subnet_2c_cidr  = var.db_private_subnet_2c_cidr
  az_2a                      = local.az_2a
  az_2c                      = local.az_2c
}

module "security" {
  source = "./modules/security"

  project_name = var.project_name
  vpc_id       = module.network.vpc_id
  vpc_cidr     = var.vpc_cidr
  admin_cidr   = var.admin_cidr
}

module "bastion" {
  source = "./modules/bastion"

  project_name              = var.project_name
  public_subnet_id          = module.network.public_subnet_2a_id # 필요시 2c로도 배포 가능
  bastion_security_group_id = module.security.bastion_sg_id
}

module "eks" {
  source = "./modules/eks"

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
}
