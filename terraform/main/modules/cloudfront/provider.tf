provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  max_retries = 5

  default_tags {
    tags = merge(
      {
        ManagedBy = "Terraform"
      },
      var.project_name == "" ? {} : { Project = var.project_name }
    )
  }
}
