
provider "aws" {
  region = var.aws_region

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
    config_path = "/home/runner/kubeconfig"
    host = "https://localhost:8443"
    cluster_ca_certificate = base64decode(module.eks.cluster_ca_data)
    insecure = true 

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
