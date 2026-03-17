# PlanIt Terraform Infrastructure

This repository contains Terraform configurations for PlanIt infrastructure on AWS, following HashiCorp's Standard Module Structure with reusable modules.

## Project Structure

```
PlanIt-Terraform/
├── main.tf                      # Root module - orchestrates all modules
├── variables.tf                 # Root module variables
├── outputs.tf                   # Root module outputs
├── providers.tf                 # Provider configurations
├── terraform.tfvars             # Development environment values (gitignored)
├── terraform.tfvars.example     # Example variable values
├── .gitignore                   # Git ignore rules
├── README.md                    # This file
│
├── environments/                # Environment-specific configurations
│   ├── dev.tfvars              # Development environment
│   └── prod.tfvars             # Production environment
│
└── modules/                     # Reusable Terraform modules
    ├── vpc/                    # VPC and Internet Gateway
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── subnets/                # Public and Private Subnets with EKS tags
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── nat-gateway/            # NAT Gateway with Elastic IP
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    ├── route-tables/           # Route Tables and Associations
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    └── eks/                    # EKS Cluster and Node Groups
        ├── main.tf             # Control tower
        ├── eks-cluster.tf      # Control Plane
        ├── eks-nodegroups.tf   # Worker Nodes
        ├── iam.tf              # IAM Roles & Policies
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## Resources Created

### Network Infrastructure
- **VPC**: Custom VPC with DNS support and hostnames enabled
- **Subnets**:
  - 1 Public subnet (Bastion) in AZ 2a
  - 2 Private subnets in AZ 2a and 2c
- **Internet Gateway**: For public subnet internet access
- **NAT Gateway**: For private subnet outbound internet access
- **Route Tables**: Separate routing for public and private subnets

### EKS Infrastructure (Optional)
- **EKS Cluster**: Managed Kubernetes cluster with control plane
- **EKS Node Groups**: Managed worker nodes in Private Subnets
- **IAM Roles**: Cluster and node group roles with required policies
- **Security Groups**: Cluster and node communication rules
- **Add-ons**: VPC CNI, CoreDNS, kube-proxy, EBS CSI driver

### EKS Tagging
All subnets are tagged for EKS cluster integration:
- Public subnet: `kubernetes.io/role/elb = 1`
- Private subnets: `kubernetes.io/role/internal-elb = 1`
- All subnets: `kubernetes.io/cluster/<cluster-name> = shared`

## Prerequisites

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials
- AWS account with necessary permissions

## Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Choose Your Environment

#### Option A: Use Development Environment (default)

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
# terraform.tfvars is gitignored for security
```

#### Option B: Use Environment-Specific Files

```bash
# For development
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"

# For production
terraform plan -var-file="environments/prod.tfvars"
terraform apply -var-file="environments/prod.tfvars"
```

### 3. Plan Infrastructure Changes

```bash
# Using default terraform.tfvars
terraform plan

# Or using environment file
terraform plan -var-file="environments/dev.tfvars"
```

### 4. Apply Infrastructure

```bash
# Using default terraform.tfvars
terraform apply

# Or using environment file
terraform apply -var-file="environments/dev.tfvars"
```

### 5. View Outputs

```bash
terraform output
```

## Module Usage

Each module can be used independently in other Terraform projects:

### VPC Module

```hcl
module "vpc" {
  source = "./modules/vpc"

  vpc_name             = "my-vpc"
  vpc_cidr             = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Environment = "dev"
  }
}
```

### Subnets Module

```hcl
module "subnets" {
  source = "./modules/subnets"

  vpc_id               = module.vpc.vpc_id
  name_prefix          = "my-project"
  public_subnet_cidrs  = ["10.0.1.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
  availability_zones   = ["ap-northeast-2a", "ap-northeast-2c"]
  eks_cluster_name     = "my-eks-cluster"

  tags = {
    Environment = "dev"
  }
}
```

See individual module READMEs for detailed documentation.

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| aws_region | AWS region | string | ap-northeast-2 | no |
| vpc_cidr | VPC CIDR block | string | 10.230.0.0/16 | no |
| public_subnet_cidr_2a | Public subnet CIDR | string | 10.230.4.0/24 | no |
| private_subnet_cidr_2a | Private subnet 2a CIDR | string | 10.230.1.0/24 | no |
| private_subnet_cidr_2c | Private subnet 2c CIDR | string | 10.230.2.0/24 | no |
| eks_cluster_name | EKS cluster name | string | terraform-eks-cluster | no |
| environment | Environment name | string | dev | no |
| project_name | Project name | string | PI | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | VPC ID |
| vpc_cidr | VPC CIDR block |
| public_subnet_ids | List of public subnet IDs |
| private_subnet_ids | List of private subnet IDs |
| nat_gateway_public_ip | NAT Gateway public IP |
| eks_subnet_ids | Subnet IDs tagged for EKS |
| eks_cluster_endpoint | EKS cluster API endpoint |
| eks_cluster_certificate_authority | EKS cluster CA data |
| eks_kubeconfig_command | Command to configure kubectl |

## EKS Cluster Management

### Enable EKS Cluster

To create an EKS cluster, set `create_eks_cluster = true` in your tfvars file:

```hcl
# terraform.tfvars or environments/dev.tfvars
create_eks_cluster = true
eks_cluster_name   = "planit-dev-eks-cluster"
```

### EKS Configuration

The EKS cluster is configured for 5 microservices:
- User-svc
- Schedule-svc
- Strategy-svc
- Insight-svc
- InsightAI-svc

Default node group settings:
- **Desired nodes**: 3
- **Min nodes**: 2
- **Max nodes**: 6
- **Instance type**: t3.medium
- **Disk size**: 20GB
- **Location**: Private Subnets (10.230.1.0/24, 10.230.2.0/24)

### Configure kubectl

After EKS cluster is created, configure kubectl:

```bash
# Get the command from Terraform output
terraform output eks_kubeconfig_command

# Or run directly
aws eks update-kubeconfig --region ap-northeast-2 --name planit-dev-eks-cluster

# Verify connection
kubectl get nodes
kubectl get pods --all-namespaces
```

### EKS Add-ons

The following add-ons are automatically installed:
- **VPC CNI**: Pod networking
- **CoreDNS**: DNS resolution
- **kube-proxy**: Network proxy
- **EBS CSI Driver**: Persistent volume support

### Deploy Applications to EKS

```bash
# Example: Deploy a service
kubectl apply -f k8s/user-svc-deployment.yaml

# Check deployment status
kubectl get deployments
kubectl get pods
kubectl get services

# View logs
kubectl logs -f <pod-name>
```

### EKS Security

- Cluster endpoint: Private + Public access (configurable)
- Node groups: Deployed in Private Subnets
- Security groups: Restricted cluster-node communication
- IAM roles: Least privilege access
- Encryption: EBS volumes encrypted by default

### EKS Scaling

```bash
# Scale node group manually
aws eks update-nodegroup-config \
  --cluster-name planit-dev-eks-cluster \
  --nodegroup-name PI-dev-node-group \
  --scaling-config desiredSize=5

# Or update in Terraform
# Set eks_node_desired_size = 5 in tfvars and apply
```

### EKS Monitoring

```bash
# View cluster info
kubectl cluster-info

# Check node status
kubectl get nodes -o wide

# View resource usage
kubectl top nodes
kubectl top pods --all-namespaces

# CloudWatch Logs
# Control plane logs are sent to CloudWatch Logs
# View in AWS Console: CloudWatch > Log groups > /aws/eks/<cluster-name>/cluster
```

### EKS Troubleshooting

```bash
# Check cluster status
aws eks describe-cluster --name planit-dev-eks-cluster

# Check node group status
aws eks describe-nodegroup \
  --cluster-name planit-dev-eks-cluster \
  --nodegroup-name PI-dev-node-group

# View events
kubectl get events --all-namespaces --sort-by='.lastTimestamp'

# Check pod issues
kubectl describe pod <pod-name>
```

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      VPC (10.230.0.0/16)                    │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Public Subnet (10.230.4.0/24) - AZ 2a              │  │
│  │  - Bastion Host                                      │  │
│  │  - NAT Gateway                                       │  │
│  │  - Internet Gateway                                  │  │
│  │  - EKS Load Balancers (external)                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Private Subnet (10.230.1.0/24) - AZ 2a             │  │
│  │  - EKS Worker Nodes (User-svc, Schedule-svc)        │  │
│  │  - EKS Load Balancers (internal)                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Private Subnet (10.230.2.0/24) - AZ 2c             │  │
│  │  - EKS Worker Nodes (Strategy, Insight, InsightAI)  │  │
│  │  - EKS Load Balancers (internal)                     │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Environment Management

### Development Environment
- CIDR: 10.230.0.0/16
- Cluster: planit-dev-eks-cluster
- File: `terraform.tfvars` or `environments/dev.tfvars`

### Production Environment
- CIDR: 10.240.0.0/16
- Cluster: planit-prod-eks-cluster
- File: `environments/prod.tfvars`

## Best Practices

1. **Never commit `terraform.tfvars`** - It's gitignored for security
2. **Use environment-specific files** for different deployments
3. **Review plans carefully** before applying
4. **Use workspaces** for managing multiple environments:
   ```bash
   terraform workspace new dev
   terraform workspace new prod
   terraform workspace select dev
   ```

## Cleanup

To destroy all resources:

```bash
# Using default terraform.tfvars
terraform destroy

# Or using environment file
terraform destroy -var-file="environments/dev.tfvars"
```

## Notes

- NAT Gateway incurs hourly charges even when idle
- Elastic IP is allocated for NAT Gateway
- All resources are tagged with Project, Environment, and ManagedBy tags
- EKS subnet tags are automatically applied for cluster integration
- Modules are designed to be reusable across different projects

## Contributing

When adding new modules:
1. Follow the standard module structure (main.tf, variables.tf, outputs.tf, README.md)
2. Include comprehensive variable descriptions
3. Add appropriate outputs
4. Document usage examples in module README
5. Apply consistent tagging strategy
