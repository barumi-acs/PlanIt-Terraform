# Route Tables Module

This module creates route tables and associations for public and private subnets.

## Resources Created

- Public Route Table (with IGW route)
- Private Route Table (with NAT route)
- Route Table Associations

## Usage

```hcl
module "route_tables" {
  source = "./modules/route-tables"

  vpc_id               = module.vpc.vpc_id
  name_prefix          = "my-project"
  internet_gateway_id  = module.vpc.internet_gateway_id
  nat_gateway_id       = module.nat_gateway.nat_gateway_id
  public_subnet_ids    = module.subnets.public_subnet_ids
  private_subnet_ids   = module.subnets.private_subnet_ids

  tags = {
    Environment = "dev"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| vpc_id | VPC ID | string | yes |
| name_prefix | Prefix for route table names | string | yes |
| internet_gateway_id | Internet Gateway ID | string | yes |
| nat_gateway_id | NAT Gateway ID | string | yes |
| public_subnet_ids | Public subnet IDs | list(string) | yes |
| private_subnet_ids | Private subnet IDs | list(string) | yes |
| tags | Tags to apply | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| public_route_table_id | Public route table ID |
| private_route_table_id | Private route table ID |
