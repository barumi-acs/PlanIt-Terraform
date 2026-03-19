
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
  }
}
