# Terraform 인프라 변경 이력

## 개요
PlanIt 프로젝트의 AWS 인프라를 GitHub Actions + ArgoCD CI/CD 파이프라인에 맞게 개선한 변경 이력입니다.

---

## [2026-03-17] Phase 1, 2, 3 완료

### Phase 1: 인프라 배포 및 검증

#### 1.1 Cognito 설정 추가
**파일**: `variables.tf`, `terraform.tfvars`

**변경 내용**:
```hcl
# variables.tf에 추가
variable "cognito_user_pool_id" {
  description = "기존 Cognito User Pool ID"
  type        = string
}

variable "cognito_client_id" {
  description = "기존 Cognito Client ID"
  type        = string
}

# terraform.tfvars에 추가
cognito_user_pool_id = "ap-northeast-2_GKpckavjT"
cognito_client_id    = "6j5ajq8p3b7d894qt5msp4hair"
```

**이유**: Frontend가 Cognito 인증을 사용하기 위해 필요

---

#### 1.2 DynamoDB 테이블 이름 수정
**파일**: `variables.tf`

**변경 전**:
```hcl
variable "dynamodb_table_name" {
  default = "PI-DEV-Insight-Dynamo"
}
```

**변경 후**:
```hcl
variable "dynamodb_table_name" {
  default = "ai_reports"
}
```

**이유**: Insight Service의 `application.yml`에서 `ai_reports` 테이블을 참조하므로 이름 통일

---

#### 1.3 Frontend Dockerfile 환경 변수 주입
**파일**: `PlanIt-FE/Dockerfile`

**변경 내용**:
- 9개 `VITE_*` 환경 변수를 ARG로 받아 ENV로 변환
- 빌드 타임에 환경 변수 주입 (Vite 특성)

**추가된 환경 변수**:
- `VITE_USER_SERVICE_URL`
- `VITE_SCHEDULE_SERVICE_URL`
- `VITE_INTELLIGENCE_SERVICE_URL`
- `VITE_INSIGHT_SERVICE_URL`
- `VITE_COGNITO_USER_POOL_ID`
- `VITE_COGNITO_CLIENT_ID`
- `VITE_COGNITO_REGION`
- `VITE_COGNITO_DOMAIN`
- `VITE_COGNITO_REDIRECT_URI`

**이유**: Vite는 빌드 타임에 환경 변수를 번들에 포함하므로 Docker 빌드 시 주입 필요

---

#### 1.4 JWT Secret 생성
**파일**: `variables.tf`, `terraform.tfvars`, `main.tf`

**변경 내용**:
```hcl
# variables.tf에 추가
variable "jwt_secret" {
  description = "JWT secret key for all backend services"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.jwt_secret) >= 32
    error_message = "jwt_secret must be at least 32 characters long for security."
  }
}

# terraform.tfvars에 추가
jwt_secret = "planit-production-jwt-secret-key-change-this-to-secure-random-string-2024"

# main.tf에 추가
resource "terraform_data" "create_jwt_secret" {
  # Kubernetes Secret 생성 로직
}
```

**이유**: 모든 Backend 서비스가 동일한 JWT Secret을 사용하여 토큰 검증

---

#### 1.5 DB Secret 서비스별 분리
**파일**: `main.tf`

**변경 전**:
- 1개의 DB Secret만 생성 (`planit-db-credentials`)

**변경 후**:
- 4개의 DB Secret 생성:
  - `planit-user-db-credentials` → `planit_user_db`
  - `planit-schedule-db-credentials` → `planit_schedule_db`
  - `planit-strategy-db-credentials` → `planit_strategy_db`
  - `planit-insight-db-credentials` → `planit_insight_db`

**이유**: 각 서비스가 자신의 DB에만 접근하도록 분리

---

#### 1.6 Redis 모듈 추가
**파일**: `modules/redis/main.tf`, `modules/redis/variables.tf`, `modules/redis/outputs.tf`

**변경 내용**:
- ElastiCache Redis 클러스터 생성
- Multi-AZ 2노드 구성 (Failover 지원)
- Redis 7.1 엔진 사용

**이유**: User Service가 Redis를 필수로 사용 (세션 관리)

---

#### 1.7 Security Group Redis SG 추가
**파일**: `modules/security/main.tf`, `modules/security/outputs.tf`

**변경 내용**:
- `aws_security_group.redis` 생성
- Node → Redis (6379 포트) 접근 허용
- Bastion → Redis (6379 포트) 접근 허용 (테스트용)

**이유**: Redis 네트워크 접근 제어

---

#### 1.8 RDS 4개 DB 자동 생성
**파일**: `main.tf`

**변경 내용**:
```hcl
resource "terraform_data" "create_databases" {
  provisioner "remote-exec" {
    inline = [
      "mysql -h ${module.rds.endpoint} -e \"CREATE DATABASE IF NOT EXISTS planit_user_db;\"",
      "mysql -h ${module.rds.endpoint} -e \"CREATE DATABASE IF NOT EXISTS planit_schedule_db;\"",
      "mysql -h ${module.rds.endpoint} -e \"CREATE DATABASE IF NOT EXISTS planit_strategy_db;\"",
      "mysql -h ${module.rds.endpoint} -e \"CREATE DATABASE IF NOT EXISTS planit_insight_db;\"",
    ]
  }
}
```

**이유**: RDS는 기본적으로 1개 DB만 생성하므로 나머지 3개를 자동 생성

---

#### 1.9 Redis CLI 자동 설치
**파일**: `main.tf`

**변경 내용**:
```hcl
resource "terraform_data" "install_redis_cli" {
  provisioner "remote-exec" {
    inline = [
      "sudo dnf install -y redis6",
    ]
  }
}
```

**이유**: Bastion에서 Redis 연결 테스트를 위해 redis6-cli 필요

---

### Phase 2: 보안 강화

#### 2.1 IRSA 설정 (Bedrock + DynamoDB)
**파일**: `modules/eks/main.tf`, `modules/eks/outputs.tf`

**변경 내용**:
- `aws_iam_role.app_services` 생성
- ServiceAccount: `planit-strategy-sa`, `planit-insightai-sa`
- 권한: `AmazonBedrockFullAccess`, `AmazonDynamoDBFullAccess`

**이유**: AWS Credentials 하드코딩 제거, IRSA로 안전하게 AWS 서비스 접근

---

#### 2.2 ACM 인증서 ARN 추가
**파일**: `variables.tf`, `terraform.tfvars`

**변경 내용**:
```hcl
# variables.tf에 추가
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS (ALB Ingress)"
  type        = string
}

# terraform.tfvars에 추가
acm_certificate_arn = "arn:aws:acm:ap-northeast-2:935875533840:certificate/a047598e-c697-443d-a037-d051f2ef733e"
```

**이유**: ALB Ingress에서 HTTPS 리스너 설정 시 필요

---

#### 2.3 GitHub Secrets 가이드 생성
**파일**: `GITHUB_SECRETS_GUIDE.md`

**내용**:
- 필수 Secrets 목록 (15개)
- GitHub Actions Workflow 예시
- 보안 주의사항
- 문제 해결 가이드

**이유**: GitHub Actions에서 Terraform 및 Frontend 빌드 시 환경 변수 관리

---

### Phase 3: 프로덕션 최적화

#### 3.1 RDS 프로덕션 설정
**파일**: `modules/rds/main.tf`

**변경 내용**:
```hcl
resource "aws_db_instance" "this" {
  deletion_protection        = true   # false → true
  skip_final_snapshot        = false  # true → false
  backup_retention_period    = 30     # 7 → 30
  final_snapshot_identifier  = "${lower(var.project_name)}-mariadb-final-snapshot-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
}
```

**이유**:
- `deletion_protection`: 실수로 RDS 삭제 방지
- `skip_final_snapshot`: 삭제 시 최종 스냅샷 생성
- `backup_retention_period`: 30일 백업 보관 (프로덕션 권장)

---

#### 3.2 Terraform Backend State 관리
**파일**: `backend.tf`

**변경 내용**:
- S3 + DynamoDB Lock 설정 (주석 처리됨)
- 사용 시 주석 해제 후 `terraform init -migrate-state` 실행

**이유**:
- Terraform State를 S3에 저장하여 팀원과 공유
- DynamoDB Lock으로 동시 작업 충돌 방지

---

#### 3.3 보안 강화 가이드 생성
**파일**: `SECURITY_HARDENING.md`

**내용**:
- admin_cidr 제한 가이드
- JWT Secret, DB Password 강화 방법
- ACM 인증서 갱신 확인
- 보안 체크리스트
- 정기 점검 항목
- 긴급 상황 대응

**이유**: 프로덕션 환경에서 보안을 강화하기 위한 필수 가이드

---

## 변경된 파일 목록

### Terraform 코드
- `variables.tf` - 변수 추가 (Cognito, JWT, ACM)
- `terraform.tfvars` - 실제 값 추가
- `main.tf` - DB 자동 생성, Redis CLI 설치, JWT Secret 생성
- `modules/rds/main.tf` - 프로덕션 설정
- `modules/redis/main.tf` - Redis 모듈 생성
- `modules/redis/variables.tf` - Redis 변수
- `modules/redis/outputs.tf` - Redis 출력
- `modules/security/main.tf` - Redis SG 추가
- `modules/security/outputs.tf` - Redis SG 출력
- `modules/eks/main.tf` - IRSA 추가
- `modules/eks/outputs.tf` - IRSA Role ARN 출력
- `backend.tf` - Backend State 설정 (신규)

### Frontend
- `PlanIt-FE/Dockerfile` - 환경 변수 주입

### 문서
- `GITHUB_SECRETS_GUIDE.md` - GitHub Secrets 가이드 (신규)
- `SECURITY_HARDENING.md` - 보안 강화 가이드 (신규)
- `CHANGELOG.md` - 변경 이력 (신규)

---

## 배포 전 체크리스트

### 필수 확인 사항
- [ ] `terraform.tfvars`에 모든 변수 값 입력 완료
- [ ] ACM 인증서가 `Issued` 상태인지 확인
- [ ] Route 53에 도메인 등록 및 CNAME 레코드 추가
- [ ] GitHub Secrets 15개 모두 설정 완료
- [ ] admin_cidr를 특정 IP로 제한 (보안 강화)

### 선택 사항
- [ ] Terraform Backend State를 S3로 마이그레이션
- [ ] JWT Secret을 더 강력한 값으로 변경
- [ ] DB Password를 더 강력한 값으로 변경

---

## 배포 순서

### 1단계: Terraform Apply
```bash
cd planit-terraform-pf
terraform init
terraform plan
terraform apply
```

### 2단계: 인프라 검증
```bash
# Bastion SSH 접속
ssh -i PI-DEV-key.pem ec2-user@<BASTION_PUBLIC_IP>

# Kubernetes Secrets 확인
kubectl get secrets -n default

# Redis 연결 테스트
/usr/bin/redis6-cli -h <REDIS_ENDPOINT> -p 6379 ping

# RDS 연결 테스트
mysql -h <RDS_ENDPOINT> -u root -p
SHOW DATABASES;
```

### 3단계: 애플리케이션 배포
- ArgoCD 설정
- Backend 서비스 배포
- Frontend 배포
- Ingress 설정

---

## 롤백 방법

### Terraform 변경 사항 롤백
```bash
cd planit-terraform-pf
git checkout <PREVIOUS_COMMIT>
terraform apply
```

### RDS 스냅샷 복원
```bash
# AWS Console → RDS → Snapshots → Restore
# 또는 AWS CLI
aws rds restore-db-instance-from-db-snapshot \
  --db-instance-identifier pi-dev-mariadb-restored \
  --db-snapshot-identifier <SNAPSHOT_ID>
```

---

## 문제 해결

### Terraform Apply 실패 시
1. 에러 메시지 확인
2. `terraform.tfvars`에 모든 변수 값이 있는지 확인
3. AWS 자격 증명이 유효한지 확인
4. 리소스 쿼터 초과 여부 확인

### Bastion 접속 불가 시
1. Security Group에서 admin_cidr 확인
2. 내 IP가 변경되었는지 확인
3. `terraform.tfvars` 수정 후 `terraform apply`

### RDS 연결 실패 시
1. Security Group에서 Node → DB 접근 허용 확인
2. RDS 엔드포인트가 올바른지 확인
3. DB Password가 올바른지 확인

---

## 참고 자료
- [Last_Test.md](./Last_Test.md) - 최종 검토 보고서
- [GITHUB_SECRETS_GUIDE.md](./GITHUB_SECRETS_GUIDE.md) - GitHub Secrets 가이드
- [SECURITY_HARDENING.md](./SECURITY_HARDENING.md) - 보안 강화 가이드
- [README.md](./README.md) - Terraform 사용 가이드

---

## 다음 단계
1. Terraform Apply 실행
2. 인프라 검증
3. ArgoCD 설정
4. 애플리케이션 배포
5. 프로덕션 배포

---

**작성일**: 2026-03-17  
**작성자**: Kiro AI Assistant  
**버전**: 1.0.0
