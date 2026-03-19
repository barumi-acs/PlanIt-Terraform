
provider "aws" {
  region = var.aws_region

  max_retries = 10 # 네트워크 불안정 시 최대 10번 재시도

  default_tags {
    tags = merge(
      {
        ManagedBy = "Terraform"
      },
      var.common_tags
    )
  }
}

# CloudFront requires ACM in us-east-1; provide an aliased provider for global CloudFront resources
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  max_retries = 10

  default_tags {
    tags = merge(
      {
        ManagedBy = "Terraform"
      },
      var.common_tags
    )
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_data)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
