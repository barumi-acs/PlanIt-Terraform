# NAT Gateway Module

This module creates a NAT Gateway with an Elastic IP.

## Resources Created

- Elastic IP
- NAT Gateway

## Usage

```hcl
module "nat_gateway" {
  source = "./modules/nat-gateway"

  name_prefix          = "my-project"
  subnet_id            = module.subnets.public_subnet_ids[0]
  internet_gateway_id  = module.vpc.internet_gateway_id

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| name_prefix | Prefix for NAT Gateway name | string | yes |
| subnet_id | Public subnet ID | string | yes |
| internet_gateway_id | Internet Gateway ID | string | yes |
| tags | Tags to apply | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| nat_gateway_id | NAT Gateway ID |
| nat_gateway_public_ip | NAT Gateway public IP |
| elastic_ip_id | Elastic IP ID |
