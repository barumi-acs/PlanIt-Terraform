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
  public_subnet_id          = module.network.public_subnet_2a_id
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

module "redis" {
  source = "./modules/redis"

  project_name            = var.project_name
  subnet_ids              = [module.network.db_private_subnet_2a_id, module.network.db_private_subnet_2c_id]
  redis_security_group_id = module.security.redis_sg_id
  redis_engine_version    = var.redis_engine_version
  redis_node_type         = var.redis_node_type
  redis_num_cache_nodes   = var.redis_num_cache_nodes
  #redis_parameter_group_name = var.redis_parameter_group_name
  #snapshot_retention_limit   = var.redis_snapshot_retention_limit
  #snapshot_window            = var.redis_snapshot_window
  #maintenance_window         = var.redis_maintenance_window
}


# ============================================
# Helm 리소스 (Bastion을 통해 실행)
# ============================================

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
      "echo '=== AWS Load Balancer Controller 설치 시작 ==='",
      "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}",
      "which helm 2>/dev/null || (curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash)",
      "helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true",
      "helm repo update eks",
      "helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n kube-system \\",
      "  --set clusterName=${module.eks.cluster_name} \\",
      "  --set serviceAccount.create=true \\",
      "  --set serviceAccount.name=aws-load-balancer-controller \\",
      "  --set serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn=${module.eks.lbc_role_arn} \\",
      "  --set region=${var.aws_region} \\",
      "  --set vpcId=${module.network.vpc_id} \\",
      "  --wait --timeout 5m0s",
      "echo '=== AWS Load Balancer Controller 설치 완료 ==='"
    ]
  }

  depends_on = [module.eks, module.bastion]
}

resource "terraform_data" "install_argocd" {
  triggers_replace = {
    cluster_name = module.eks.cluster_name
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
      "echo '=== ArgoCD 및 도구 설치 준비 시작 ==='",
      
      # bash-completion 설치 (자동완성 필수 패키지)
      "sudo dnf install -y bash-completion",

      # kubectl 설치 (없을 경우)
      "if ! command -v kubectl &> /dev/null; then",
      "  echo 'kubectl 설치 중...'",
      "  curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
      "  chmod +x kubectl",
      "  sudo mv kubectl /usr/local/bin/",
      "fi",

      # kubectl 자동완성 설정 (영구 적용)
      "echo 'kubectl 자동완성 설정 중...'",
      "kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null",
      "grep -q 'kubectl completion bash' ~/.bashrc || echo 'source <(kubectl completion bash)' >> ~/.bashrc",

      # helm 설치 (없을 경우)
      "if ! command -v helm &> /dev/null; then",
      "  echo 'helm 설치 중...'",
      "  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash",
      "fi",

      "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}",
      
      "echo '=== ArgoCD 설치 시작 ==='",
      "helm repo add argo https://argoproj.github.io/argo-helm 2>/dev/null || true",
      "helm repo update argo",
      "kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -",
      "helm upgrade --install argocd argo/argo-cd --version 5.51.6 -n argocd \\",
      "  --set server.service.type=LoadBalancer \\",
      "  --wait --timeout 5m0s",
      "echo '=== ArgoCD 설치 완료 ==='"
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

# ============================================
# Secrets Manager Module (AWS SM → CSI Driver → K8s Secret 자동 동기화)
# ============================================
module "secrets" {
  source = "./modules/secrets"

  project_name          = var.project_name
  environment           = var.environment
  k8s_namespace         = "planit-${var.environment}"
  oidc_provider_arn     = module.eks.oidc_provider_arn
  oidc_issuer           = module.eks.oidc_issuer
  db_username           = var.db_username
  db_password           = var.db_password
  aws_access_key_id     = var.aws_access_key_id
  aws_secret_access_key = var.aws_secret_access_key
  cognito_client_secret = var.cognito_client_secret
  jwt_secret            = var.jwt_secret
  gnews_api_key         = var.gnews_api_key

  depends_on = [module.eks]
}

# RDS에 4개 DB 자동 생성
resource "terraform_data" "create_databases" {
  triggers_replace = {
    rds_endpoint = module.rds.endpoint
    db_password  = var.db_password
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
      "echo '=== RDS에 4개 데이터베이스 생성 시작 ==='",

      # MariaDB 클라이언트 설치 (없는 경우)
      "sudo dnf install -y mariadb105 2>/dev/null || echo 'MariaDB client already installed'",

      # 4개 DB 생성 (이미 존재하면 무시)
      "mysql -h ${module.rds.endpoint} -P 3306 -u ${var.db_username} -p'${var.db_password}' -e \"CREATE DATABASE IF NOT EXISTS planit_user_db;\"",
      "mysql -h ${module.rds.endpoint} -P 3306 -u ${var.db_username} -p'${var.db_password}' -e \"CREATE DATABASE IF NOT EXISTS planit_schedule_db;\"",
      "mysql -h ${module.rds.endpoint} -P 3306 -u ${var.db_username} -p'${var.db_password}' -e \"CREATE DATABASE IF NOT EXISTS planit_strategy_db;\"",
      "mysql -h ${module.rds.endpoint} -P 3306 -u ${var.db_username} -p'${var.db_password}' -e \"CREATE DATABASE IF NOT EXISTS planit_insight_db;\"",

      # 확인
      "echo '=== 생성된 데이터베이스 목록 ==='",
      "mysql -h ${module.rds.endpoint} -P 3306 -u ${var.db_username} -p'${var.db_password}' -e \"SHOW DATABASES;\" | grep planit",

      "echo '=== RDS 데이터베이스 생성 완료 ==='",
    ]
  }

  depends_on = [module.rds, module.bastion]
}

# Redis CLI 자동 설치
resource "terraform_data" "install_redis_cli" {
  triggers_replace = {
    bastion_id = module.bastion.instance_id
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
      "echo '=== Redis CLI 설치 시작 ==='",
      "sudo dnf install -y redis6",
      "echo '=== Redis CLI 설치 완료 ==='",
      "/usr/bin/redis6-cli --version",
    ]
  }

  depends_on = [module.bastion]
}

# Kubernetes DB Secrets는 AWS Secrets Manager → CSI Driver를 통해 자동 동기화됩니다.
# PlanIt-Yaml/common/secret-provider-class.yaml 참고

module "s3_frontend" {
  source = "./modules/s3_frontend"

  bucket_name  = var.frontend_bucket_name
  project_name = var.project_name
}

module "cloudfront" {
  source = "./modules/cloudfront"

  bucket_domain_name  = module.s3_frontend.bucket_regional_domain_name
  project_name        = var.project_name
  acm_certificate_arn = trimspace(var.acm_certificate_arn_virginia)
  aliases             = var.external_dns_domain_filters
}