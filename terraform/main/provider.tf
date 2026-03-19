terraform {  
  backend "s3" {
    bucket         = "planit-team-tfstate-bucket"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

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
