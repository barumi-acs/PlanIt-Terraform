# 보안 강화 가이드

## 개요
프로덕션 환경에서 보안을 강화하기 위한 필수 설정 가이드입니다.

---

## 1. admin_cidr 제한 (필수)

### 현재 상태
```hcl
# terraform.tfvars
admin_cidr = "0.0.0.0/0"  # ⚠️ 모든 IP 허용 (위험!)
```

### 권장 설정
```hcl
# terraform.tfvars
admin_cidr = "YOUR_IP/32"  # ✅ 특정 IP만 허용
```

### 내 IP 확인 방법

#### 방법 1: 웹사이트
```bash
# 브라우저에서 접속
https://whatismyipaddress.com/
```

#### 방법 2: CLI
```bash
# Linux/Mac
curl ifconfig.me

# Windows PowerShell
(Invoke-WebRequest -Uri "https://ifconfig.me").Content
```

### 설정 예시
```hcl
# 예시 1: 단일 IP
admin_cidr = "203.0.113.10/32"

# 예시 2: 회사 네트워크 (C 클래스)
admin_cidr = "203.0.113.0/24"

# 예시 3: 여러 IP (Terraform에서는 불가능, Security Group에서 직접 추가 필요)
# admin_cidr는 하나의 CIDR만 지원
```

### 적용 방법
1. `terraform.tfvars` 파일 수정
2. `terraform apply` 실행
3. Bastion Security Group이 자동으로 업데이트됨

---

## 2. RDS 프로덕션 설정 (완료)

### 적용된 설정
```hcl
# modules/rds/main.tf
resource "aws_db_instance" "this" {
  deletion_protection        = true   # 실수로 삭제 방지
  skip_final_snapshot        = false  # 삭제 시 최종 스냅샷 생성
  backup_retention_period    = 30     # 30일 백업 보관
}
```

### 주의사항
- `deletion_protection = true`로 설정하면 RDS를 삭제할 수 없습니다
- 삭제하려면 먼저 `deletion_protection = false`로 변경 후 `terraform apply` 실행
- 그 다음 `terraform destroy` 실행

---

## 3. Terraform Backend State 관리 (선택)

### 현재 상태
- Terraform State 파일이 로컬에 저장됨 (`terraform.tfstate`)
- 팀원과 공유 불가능
- 동시 작업 시 충돌 가능

### 권장 설정
- S3에 State 파일 저장
- DynamoDB로 State Lock 관리
- 팀원과 안전하게 공유 가능

### 설정 방법

#### 1단계: S3 버킷 생성
```bash
# S3 버킷 생성
aws s3api create-bucket \
  --bucket planit-terraform-state-prod \
  --region ap-northeast-2 \
  --create-bucket-configuration LocationConstraint=ap-northeast-2

# 버전 관리 활성화
aws s3api put-bucket-versioning \
  --bucket planit-terraform-state-prod \
  --versioning-configuration Status=Enabled

# 암호화 활성화
aws s3api put-bucket-encryption \
  --bucket planit-terraform-state-prod \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'
```

#### 2단계: DynamoDB 테이블 생성
```bash
aws dynamodb create-table \
  --table-name planit-terraform-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region ap-northeast-2
```

#### 3단계: backend.tf 주석 해제
```hcl
# backend.tf 파일에서 주석 제거
terraform {
  backend "s3" {
    bucket         = "planit-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "planit-terraform-lock"
  }
}
```

#### 4단계: State 마이그레이션
```bash
cd planit-terraform-pf
terraform init -migrate-state
```

---

## 4. AWS Credentials 하드코딩 제거 (완료)

### 적용된 설정
- IRSA (IAM Roles for Service Accounts) 설정 완료
- Strategy Service와 InsightAI Service가 IAM Role 사용
- Bedrock + DynamoDB 접근 권한 부여

### Deployment에서 사용 방법
```yaml
# strategy-deployment.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: planit-strategy-sa
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::935875533840:role/PI-DEV-App-Services-Role
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: planit-strategy-svc
spec:
  template:
    spec:
      serviceAccountName: planit-strategy-sa  # ← IRSA 사용
      containers:
      - name: strategy
        image: 935875533840.dkr.ecr.ap-northeast-2.amazonaws.com/planit-strategy-svc:latest
        # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY 환경 변수 불필요!
```

---

## 5. JWT Secret 관리

### 현재 설정
```hcl
# terraform.tfvars
jwt_secret = "planit-production-jwt-secret-key-change-this-to-secure-random-string-2024"
```

### 권장 사항
- 최소 32자 이상 (현재 충족)
- 랜덤 문자열 사용 권장
- 정기적으로 변경 (6개월마다)

### 강력한 Secret 생성 방법
```bash
# Linux/Mac
openssl rand -base64 48

# Windows PowerShell
[Convert]::ToBase64String((1..48 | ForEach-Object { Get-Random -Minimum 0 -Maximum 256 }))

# Python
python3 -c "import secrets; print(secrets.token_urlsafe(48))"
```

---

## 6. DB Password 관리

### 현재 설정
```hcl
# terraform.tfvars
db_password = "rootroot"  # ⚠️ 약한 비밀번호
```

### 권장 설정
- 최소 12자 이상
- 대소문자, 숫자, 특수문자 포함
- 정기적으로 변경 (3개월마다)

### 강력한 Password 생성 방법
```bash
# Linux/Mac
openssl rand -base64 16

# Windows PowerShell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | ForEach-Object {[char]$_})

# Python
python3 -c "import secrets; print(secrets.token_urlsafe(16))"
```

---

## 7. ACM 인증서 갱신

### 현재 설정
- ACM 인증서: `arn:aws:acm:ap-northeast-2:935875533840:certificate/a047598e-c697-443d-a037-d051f2ef733e`
- DNS 검증 방식 사용 (자동 갱신)

### 주의사항
- ACM 인증서는 **자동으로 갱신**됩니다 (DNS 검증 시)
- Route 53에 CNAME 레코드가 유지되어야 합니다
- 인증서 만료 60일 전부터 갱신 시작
- AWS가 자동으로 이메일 알림 발송

### 확인 방법
```bash
# AWS CLI로 인증서 상태 확인
aws acm describe-certificate \
  --certificate-arn arn:aws:acm:ap-northeast-2:935875533840:certificate/a047598e-c697-443d-a037-d051f2ef733e \
  --region ap-northeast-2
```

---

## 8. 보안 체크리스트

### 인프라 보안
- [ ] admin_cidr를 특정 IP로 제한
- [ ] RDS deletion_protection 활성화
- [ ] RDS 백업 30일 보관
- [ ] Terraform State를 S3에 저장
- [ ] DynamoDB Lock 활성화

### 자격 증명 보안
- [ ] AWS Credentials 하드코딩 제거 (IRSA 사용)
- [ ] JWT Secret 강력한 값으로 변경
- [ ] DB Password 강력한 값으로 변경
- [ ] GitHub Secrets 설정 완료
- [ ] ACM 인증서 자동 갱신 확인

### 네트워크 보안
- [ ] Bastion만 Public Subnet에 배치
- [ ] EKS Node는 Private Subnet에 배치
- [ ] RDS는 Private Subnet에 배치
- [ ] Security Group 최소 권한 원칙 적용
- [ ] ALB Ingress HTTPS 리스너 설정

### 모니터링
- [ ] CloudWatch 로그 활성화
- [ ] RDS 성능 모니터링 활성화
- [ ] EKS 클러스터 로깅 활성화
- [ ] 비용 알림 설정

---

## 9. 정기 점검 항목

### 매월
- [ ] AWS 비용 확인
- [ ] RDS 백업 상태 확인
- [ ] ACM 인증서 만료일 확인
- [ ] Security Group 규칙 검토

### 분기별 (3개월)
- [ ] DB Password 변경
- [ ] IAM 사용자 Access Key 로테이션
- [ ] 사용하지 않는 리소스 정리

### 반기별 (6개월)
- [ ] JWT Secret 변경
- [ ] Terraform 버전 업데이트
- [ ] EKS Kubernetes 버전 업데이트

---

## 10. 긴급 상황 대응

### RDS 장애 시
1. AWS Console → RDS → 이벤트 확인
2. Multi-AZ 자동 Failover 확인 (약 1-2분 소요)
3. 애플리케이션 재연결 확인

### EKS Node 장애 시
1. `kubectl get nodes` 로 노드 상태 확인
2. Auto Scaling Group이 자동으로 새 노드 생성
3. Pod가 새 노드로 자동 이동 확인

### Bastion 접속 불가 시
1. Security Group에서 admin_cidr 확인
2. 내 IP가 변경되었는지 확인
3. terraform.tfvars 수정 후 terraform apply

---

## 참고 자료
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [EKS Security Best Practices](https://aws.github.io/aws-eks-best-practices/security/docs/)
