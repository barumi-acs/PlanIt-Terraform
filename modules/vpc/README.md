# VPC Module

This module creates an AWS VPC with an Internet Gateway.

## Resources Created

- AWS VPC
- Internet Gateway

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "my-vpc"
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Environment = "dev"
    Project     = "MyProject"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| vpc_name | Name of the VPC | string | - | yes |
| vpc_cidr | CIDR block for the VPC | string | - | yes |
| enable_dns_support | Enable DNS support | bool | true | no |
| enable_dns_hostnames | Enable DNS hostnames | bool | true | no |
| tags | Tags to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| vpc_arn | VPC ARN |
| internet_gateway_id | Internet Gateway ID |
