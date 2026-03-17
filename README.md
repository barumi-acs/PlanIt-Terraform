# PI-DEV Terraform Infra

요청하신 구조를 모듈형으로 나눈 Terraform 코드입니다.

## 포함 리소스
- VPC, IGW, NAT(2A), Public/Private Subnet(2A/2C), 라우팅 테이블
- Bastion EC2 (SSH 22는 `admin_cidr`만 허용)
- Security Groups
  - ALB SG: 80/443 오픈
  - Node SG: NodePort 30000-32767 (ALB SG에서)
  - Cluster SG: 443 (Node/Bastion에서)
  - DB SG: 3306 (Node/Bastion에서)
- ALB는 Terraform으로 선생성하지 않고, EKS Ingress(aws-load-balancer-controller)에서 생성
- 필요 시 Ingress annotation에서 `alb_sg_id` 출력값을 ALB SG로 지정 가능
- EKS Cluster + Managed Node Group (`t3.micro`, AL2023)
- RDS MariaDB Multi-AZ
- S3 Bucket (Public Access 허용)

## 사용 방법
1. 초기화
   ```bash
   terraform init
   ```
2. 변수 파일 생성
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
3. `terraform.tfvars` 값 수정
4. 실행
   ```bash
   terraform plan
   terraform apply
   ```

## 주의 사항
- S3 버킷 이름은 글로벌 유니크여야 합니다.
- MariaDB `10.11.9` 버전은 리전 가용성에 따라 실패할 수 있으니 필요 시 `db_engine_version`을 조정하세요.
- EKS 버전도 시점/리전에 따라 변경이 필요할 수 있습니다.
