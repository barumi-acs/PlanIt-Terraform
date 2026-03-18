# PlanIt Terraform Infrastructure

PlanIt 애플리케이션을 위한 AWS 인프라를 Terraform으로 관리합니다.

## 아키텍처

- **VPC**: 10.230.0.0/16
- **EKS**: Kubernetes 1.33
- **RDS**: MariaDB 10.11.9 (Multi-AZ)
- **Cognito**: 사용자 인증
- **S3**: 정적 파일 저장
- **DynamoDB**: Insight 데이터
- **Bastion**: SSH 접근

## 빠른 시작

### 1. 사전 요구사항

- AWS CLI 설치 및 구성
- Terraform 1.5+ 설치
- SSH 키페어 생성

### 2. 변수 설정

`terraform.tfvars` 파일 생성:

```hcl
admin_cidr  = "YOUR_IP/32"
db_password = "YOUR_DB_PASSWORD"
```

### 3. 인프라 배포

```bash
terraform init
terraform plan
terraform apply
```


## 생성되는 리소스

### 네트워크
- VPC (10.230.0.0/16)
- Public Subnet 2개 (2a, 2c)
- Private Subnet 4개 (EKS 2개, DB 2개)
- Internet Gateway
- NAT Gateway

### 컴퓨팅
- EKS Cluster (v1.33)
- EKS Node Group (t3.medium, 2-3 nodes)
- Bastion EC2 (t3.micro)

### 데이터베이스
- RDS MariaDB (Multi-AZ)
- 4개 데이터베이스 자동 생성:
  - planit_user_db
  - planit_schedule_db
  - planit_insight_db
  - planit_strategy_db

### 인증
- Cognito User Pool
- Cognito User Pool Client
- Kubernetes Secret 자동 생성

### 스토리지
- S3 Bucket
- DynamoDB Table

### Kubernetes 애드온
- AWS Load Balancer Controller
- External DNS


## 주요 명령어

### Terraform 기본

```bash
# 초기화
terraform init

# 계획 확인
terraform plan

# 인프라 생성
terraform apply

# 인프라 삭제
terraform destroy

# 특정 리소스만 삭제
terraform destroy -target=module.cognito
```

### Output 확인

```bash
# 모든 output 확인
terraform output

# 특정 output 확인
terraform output eks_cluster_name
terraform output cognito_user_pool_id
terraform output rds_endpoint
```

### EKS 연결

```bash
# kubeconfig 업데이트
aws eks update-kubeconfig --region ap-northeast-2 --name PI-DEV-Cluster

# 노드 확인
kubectl get nodes

# Pod 확인
kubectl get pods -A
```


## Kubernetes Secret 관리

Terraform이 자동으로 생성하는 Secret:

### 1. Cognito Secret
```bash
# Secret 확인
kubectl get secret planit-cognito-config -n default

# 값 확인
kubectl get secret planit-cognito-config -n default -o jsonpath='{.data.user-pool-id}' | base64 -d
```

### 2. DB Secret
```bash
# Secret 확인
kubectl get secret planit-db-credentials -n default

# 값 확인
kubectl get secret planit-db-credentials -n default -o jsonpath='{.data.url}' | base64 -d
```

### 수동 Secret 생성 (필요시)

```bash
# Cognito Secret
./scripts/create-k8s-secrets.sh

# 또는 수동으로
kubectl create secret generic planit-cognito-config \
  --from-literal=user-pool-id=$(terraform output -raw cognito_user_pool_id) \
  --from-literal=client-id=$(terraform output -raw cognito_client_id) \
  -n default
```


## 디렉토리 구조

```
planit-terraform-pf/
├── main.tf                    # 메인 Terraform 설정
├── variables.tf               # 변수 정의
├── outputs.tf                 # Output 정의
├── terraform.tfvars           # 변수 값 (gitignore)
├── README.md                  # 이 문서
├── COGNITO_SETUP_GUIDE.md     # Cognito 설정 가이드
├── modules/                   # Terraform 모듈
│   ├── network/              # VPC, Subnet, Gateway
│   ├── security/             # Security Groups
│   ├── bastion/              # Bastion 서버
│   ├── eks/                  # EKS 클러스터
│   ├── rds/                  # RDS 데이터베이스
│   ├── s3/                   # S3 버킷
│   ├── dynamodb/             # DynamoDB 테이블
│   └── cognito/              # Cognito User Pool
└── scripts/                   # 유틸리티 스크립트
    └── create-k8s-secrets.sh # Secret 생성 스크립트
```


## 트러블슈팅

### 문제 1: Bastion 연결 실패

```bash
# SSH 키 권한 확인
chmod 400 PI-DEV-key.pem

# Bastion IP 확인
terraform output bastion_public_ip

# SSH 연결 테스트
ssh -i PI-DEV-key.pem ec2-user@<bastion-ip>
```

### 문제 2: EKS 연결 실패

```bash
# kubeconfig 재설정
aws eks update-kubeconfig --region ap-northeast-2 --name PI-DEV-Cluster

# IAM 권한 확인
aws sts get-caller-identity
```

### 문제 3: RDS 연결 실패

```bash
# Bastion을 통해 RDS 연결 테스트
ssh -i PI-DEV-key.pem ec2-user@<bastion-ip>
mysql -h <rds-endpoint> -u root -p
```

### 문제 4: Cognito Secret 없음

```bash
# Secret 수동 생성
./scripts/create-k8s-secrets.sh

# 또는 Terraform 재실행
terraform apply -target=terraform_data.create_cognito_secret
```


## 보안 주의사항

### 1. 민감한 정보 관리

```bash
# terraform.tfvars는 절대 Git에 커밋하지 마세요
echo "terraform.tfvars" >> .gitignore
echo "*.pem" >> .gitignore
echo ".terraform/" >> .gitignore
```

### 2. State 파일 보안

현재는 로컬 state를 사용하지만, 프로덕션에서는 S3 backend 사용 권장:

```hcl
terraform {
  backend "s3" {
    bucket = "planit-terraform-state"
    key    = "dev/terraform.tfstate"
    region = "ap-northeast-2"
    encrypt = true
  }
}
```

### 3. admin_cidr 제한

`admin_cidr`을 `0.0.0.0/0`으로 설정하지 마세요. 본인 IP만 허용:

```hcl
admin_cidr = "YOUR_IP/32"
```


## 비용 최적화

### 개발 환경 리소스 중지

```bash
# EKS Node Group 스케일 다운
aws eks update-nodegroup-config \
  --cluster-name PI-DEV-Cluster \
  --nodegroup-name PI-DEV-node-group \
  --scaling-config minSize=0,maxSize=3,desiredSize=0

# RDS 중지 (최대 7일)
aws rds stop-db-instance --db-instance-identifier <rds-id>
```

### 비용 예상 (월간, ap-northeast-2 기준)

- EKS Control Plane: $73
- EC2 (t3.medium x2): $60
- RDS (db.t3.medium, Multi-AZ): $120
- NAT Gateway: $32
- Bastion (t3.micro): $8
- 기타 (S3, DynamoDB, Cognito): $5

**총 예상 비용: 약 $300/월**


## 참고 문서

- [COGNITO_SETUP_GUIDE.md](./COGNITO_SETUP_GUIDE.md) - Cognito 설정 상세 가이드
- [AWS EKS 공식 문서](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 라이선스

이 프로젝트는 PlanIt 팀의 소유입니다.
