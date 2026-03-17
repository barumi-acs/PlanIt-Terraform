# Subnets Module

This module creates public and private subnets with EKS tagging.

## Resources Created

- Public Subnets (with EKS ELB tags)
- Private Subnets (with EKS internal-ELB tags)

## Usage

```hcl
module "subnets" {
  source = "./modules/subnets"

  vpc_id               = module.vpc.vpc_id
  name_prefix          = "my-project"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  eks_cluster_name     = "my-eks-cluster"

  tags = {
    Environment = "dev"
  }
}
```

## EKS Tags Applied

- Public subnets: `kubernetes.io/role/elb = 1`
- Private subnets: `kubernetes.io/role/internal-elb = 1`
- All subnets: `kubernetes.io/cluster/<cluster-name> = shared`

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vpc_id | VPC ID | string | yes |
| name_prefix | Prefix for subnet names | string | yes |
| public_subnet_cidrs | Public subnet CIDRs | list(string) | yes |
| private_subnet_cidrs | Private subnet CIDRs | list(string) | yes |
| availability_zones | Availability zones | list(string) | yes |
| eks_cluster_name | EKS cluster name | string | yes |
| tags | Tags to apply | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| public_subnet_ids | Public subnet IDs |
| private_subnet_ids | Private subnet IDs |
| all_subnet_ids | All subnet IDs |
