# Migration Guide

## Overview

This guide explains the migration from numbered files to HashiCorp Standard Module Structure.

## Old Structure vs New Structure

### Old Structure (Numbered Files)
```
00.variables.tf
01.provider.tf
01.security_group.tf
02.ec2.tf
02.vpc.tf
03.subnet.tf
04.igw.tf
05.nat.tf
06.routing_table.tf
07.route53.tf
08.acm.tf
09.s3.tf
```

### New Structure (Standard Module)
```
├── main.tf                    # Module orchestration
├── variables.tf               # All variables
├── outputs.tf                 # All outputs
├── providers.tf               # Provider config
├── security-groups.tf         # Security groups
├── ec2.tf                     # EC2 instances
├── route53.tf                 # Route53 zones
├── acm.tf                     # ACM certificates
├── s3.tf                      # S3 buckets
├── terraform.tfvars           # Dev environment (gitignored)
├── terraform.tfvars.example   # Example values
├── .gitignore                 # Git ignore rules
│
├── environments/
│   ├── dev.tfvars            # Development
│   └── prod.tfvars           # Production
│
└── modules/
    ├── vpc/                  # VPC + IGW
    ├── subnets/              # Subnets with EKS tags
    ├── nat-gateway/          # NAT + EIP
    └── route-tables/         # Route tables + associations
```

## Key Changes

### 1. Module-Based Architecture
- VPC, Subnets, NAT Gateway, and Route Tables are now reusable modules
- Each module has its own main.tf, variables.tf, outputs.tf, and README.md

### 2. Consolidated Files
- All variables in one `variables.tf`
- All outputs in one `outputs.tf`
- Resource-specific files (ec2.tf, s3.tf, etc.)

### 3. Environment Management
- `terraform.tfvars` for default/dev (gitignored)
- `environments/dev.tfvars` for explicit dev
- `environments/prod.tfvars` for production

### 4. Feature Flags
Optional resources controlled by variables:
- `create_bastion_instance` - EC2 bastion
- `create_route53_zone` - Route53 hosted zone
- `create_acm_certificate` - ACM certificate
- `create_s3_bucket` - S3 bucket

### 5. Fixed Issues
- **NAT Gateway naming**: Fixed incorrect reference `pi_dev_igw` → `pi_dev_nat_2a`
- **Consistent naming**: All resources follow `${project_name}-${environment}` pattern
- **EKS tags**: Properly applied to all subnets

## Migration Steps

### Option 1: Fresh Start (Recommended)
1. Backup old state: `cp terraform.tfstate terraform.tfstate.backup`
2. Destroy old resources: `terraform destroy` (using old files)
3. Initialize new structure: `terraform init`
4. Apply new structure: `terraform apply`

### Option 2: State Migration (Advanced)
```bash
# Import existing resources to new structure
terraform import module.vpc.aws_vpc.this <vpc-id>
terraform import module.subnets.aws_subnet.public[0] <subnet-id>
# ... continue for all resources
```

## Usage Examples

### Basic Network Only
```bash
# Using default terraform.tfvars
terraform init
terraform plan
terraform apply
```

### With Optional Resources
```hcl
# In terraform.tfvars
create_bastion_instance = true
ec2_key_name            = "my-key"
bastion_private_ip      = "10.230.4.240"

create_s3_bucket = true
s3_bucket_name   = "my-bucket-name"
```

### Environment-Specific Deployment
```bash
# Development
terraform apply -var-file="environments/dev.tfvars"

# Production
terraform apply -var-file="environments/prod.tfvars"
```

## Backward Compatibility

The new structure creates the same resources as the old numbered files:
- ✅ VPC with same CIDR
- ✅ Same subnet configuration
- ✅ Same EKS tags
- ✅ Same NAT Gateway setup
- ✅ Same route table associations

## What to Delete

After successful migration, you can safely delete:
```
00.variables.tf
01.provider.tf
01.security_group.tf
02.ec2.tf
02.vpc.tf
03.subnet.tf
04.igw.tf
05.nat.tf
06.routing_table.tf
07.route53.tf
08.acm.tf
09.s3.tf
```

## Troubleshooting

### Issue: Resource already exists
```bash
# Import existing resource
terraform import <resource_address> <resource_id>
```

### Issue: State mismatch
```bash
# Refresh state
terraform refresh
```

### Issue: Module not found
```bash
# Reinitialize
terraform init -upgrade
```

## Benefits of New Structure

1. **Reusability**: Modules can be used in other projects
2. **Maintainability**: Clear separation of concerns
3. **Scalability**: Easy to add new environments
4. **Best Practices**: Follows HashiCorp standards
5. **Documentation**: Each module has its own README
6. **Version Control**: Proper .gitignore for sensitive data
7. **Flexibility**: Feature flags for optional resources

## Testing the New Structure

### 1. Validate Configuration
```bash
terraform init
terraform validate
```

### 2. Check Plan
```bash
# Development
terraform plan -var-file="environments/dev.tfvars"

# Production
terraform plan -var-file="environments/prod.tfvars"
```

### 3. Format Code
```bash
terraform fmt -recursive
```

## Next Steps

1. Review the new structure
2. Update `terraform.tfvars` with your values
3. Run `terraform init`
4. Run `terraform plan` to preview changes
5. Run `terraform apply` when ready
6. Delete old numbered files after successful migration

## Support

For questions or issues:
1. Check module READMEs in `modules/` directory
2. Review `MIGRATION_GUIDE.md`
3. Consult main `README.md`
