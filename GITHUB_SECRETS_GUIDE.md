# GitHub Secrets 설정 가이드

## 개요
GitHub Actions에서 Terraform 및 Frontend 빌드 시 필요한 환경 변수를 GitHub Secrets로 관리합니다.

## 설정 방법
1. GitHub 저장소 → Settings → Secrets and variables → Actions
2. "New repository secret" 클릭
3. 아래 목록의 Secret을 하나씩 추가

---

## 필수 Secrets 목록

### 1. AWS 자격 증명 (Terraform용)

#### `AWS_ACCESS_KEY_ID`
- **설명**: AWS IAM 사용자의 Access Key ID
- **값**: `AKIA...` 형식
- **용도**: Terraform이 AWS 리소스를 생성/수정/삭제

#### `AWS_SECRET_ACCESS_KEY`
- **설명**: AWS IAM 사용자의 Secret Access Key
- **값**: 40자 랜덤 문자열
- **용도**: AWS_ACCESS_KEY_ID와 함께 사용

---

### 2. Terraform 변수 (민감 정보)

#### `TF_VAR_admin_cidr`
- **설명**: Bastion SSH 접근 허용 IP
- **값**: `YOUR_IP/32` (예: `203.0.113.10/32`)
- **용도**: 보안 강화 (특정 IP만 Bastion 접근 허용)

#### `TF_VAR_db_password`
- **설명**: RDS MariaDB root 비밀번호
- **값**: `rootroot` (현재 값) 또는 더 강력한 비밀번호
- **용도**: RDS 데이터베이스 접근

#### `TF_VAR_jwt_secret`
- **설명**: JWT 토큰 서명용 Secret Key
- **값**: `planit-production-jwt-secret-key-change-this-to-secure-random-string-2024`
- **용도**: 모든 Backend 서비스의 JWT 토큰 검증

#### `TF_VAR_cognito_user_pool_id`
- **설명**: Cognito User Pool ID
- **값**: `ap-northeast-2_GKpckavjT`
- **용도**: 사용자 인증

#### `TF_VAR_cognito_client_id`
- **설명**: Cognito Client ID
- **값**: `6j5ajq8p3b7d894qt5msp4hair`
- **용도**: 사용자 인증

#### `TF_VAR_acm_certificate_arn`
- **설명**: ACM 인증서 ARN (HTTPS용)
- **값**: `arn:aws:acm:ap-northeast-2:935875533840:certificate/a047598e-c697-443d-a037-d051f2ef733e`
- **용도**: ALB Ingress HTTPS 리스너

---

### 3. Frontend 빌드 환경 변수 (Docker 빌드용)

#### `VITE_USER_SERVICE_URL`
- **설명**: User Service API 엔드포인트
- **값**: `https://api.barumi-planit.store` (프로덕션)
- **용도**: Frontend가 User Service 호출

#### `VITE_SCHEDULE_SERVICE_URL`
- **설명**: Schedule Service API 엔드포인트
- **값**: `https://api.barumi-planit.store` (프로덕션)
- **용도**: Frontend가 Schedule Service 호출

#### `VITE_INTELLIGENCE_SERVICE_URL`
- **설명**: Intelligence Service API 엔드포인트
- **값**: `https://api.barumi-planit.store` (프로덕션)
- **용도**: Frontend가 Intelligence Service 호출

#### `VITE_INSIGHT_SERVICE_URL`
- **설명**: Insight Service API 엔드포인트
- **값**: `https://api.barumi-planit.store` (프로덕션)
- **용도**: Frontend가 Insight Service 호출

#### `VITE_COGNITO_USER_POOL_ID`
- **설명**: Cognito User Pool ID
- **값**: `ap-northeast-2_GKpckavjT`
- **용도**: Frontend Cognito 인증

#### `VITE_COGNITO_CLIENT_ID`
- **설명**: Cognito Client ID
- **값**: `6j5ajq8p3b7d894qt5msp4hair`
- **용도**: Frontend Cognito 인증

#### `VITE_COGNITO_REGION`
- **설명**: Cognito 리전
- **값**: `ap-northeast-2`
- **용도**: Frontend Cognito 인증

#### `VITE_COGNITO_DOMAIN`
- **설명**: Cognito 도메인
- **값**: `YOUR_COGNITO_DOMAIN.auth.ap-northeast-2.amazoncognito.com`
- **용도**: Frontend Cognito 인증

#### `VITE_COGNITO_REDIRECT_URI`
- **설명**: Cognito 인증 후 리다이렉트 URI
- **값**: `https://barumi-planit.store/auth/callback` (프로덕션)
- **용도**: Frontend Cognito 인증 콜백

---

## GitHub Actions Workflow 예시

### Terraform Apply Workflow

```yaml
name: Terraform Apply

on:
  push:
    branches: [main]
    paths:
      - 'planit-terraform-pf/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.5.0
      
      - name: Terraform Init
        working-directory: planit-terraform-pf
        run: terraform init
      
      - name: Terraform Plan
        working-directory: planit-terraform-pf
        env:
          TF_VAR_admin_cidr: ${{ secrets.TF_VAR_admin_cidr }}
          TF_VAR_db_password: ${{ secrets.TF_VAR_db_password }}
          TF_VAR_jwt_secret: ${{ secrets.TF_VAR_jwt_secret }}
          TF_VAR_cognito_user_pool_id: ${{ secrets.TF_VAR_cognito_user_pool_id }}
          TF_VAR_cognito_client_id: ${{ secrets.TF_VAR_cognito_client_id }}
          TF_VAR_acm_certificate_arn: ${{ secrets.TF_VAR_acm_certificate_arn }}
        run: terraform plan
      
      - name: Terraform Apply
        working-directory: planit-terraform-pf
        env:
          TF_VAR_admin_cidr: ${{ secrets.TF_VAR_admin_cidr }}
          TF_VAR_db_password: ${{ secrets.TF_VAR_db_password }}
          TF_VAR_jwt_secret: ${{ secrets.TF_VAR_jwt_secret }}
          TF_VAR_cognito_user_pool_id: ${{ secrets.TF_VAR_cognito_user_pool_id }}
          TF_VAR_cognito_client_id: ${{ secrets.TF_VAR_cognito_client_id }}
          TF_VAR_acm_certificate_arn: ${{ secrets.TF_VAR_acm_certificate_arn }}
        run: terraform apply -auto-approve
```

### Frontend Build & Push Workflow

```yaml
name: Build and Push Frontend

on:
  push:
    branches: [main]
    paths:
      - 'PlanIt-FE/**'

jobs:
  build-frontend:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ap-northeast-2
      
      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1
      
      - name: Build Frontend Docker Image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build \
            --build-arg VITE_USER_SERVICE_URL=${{ secrets.VITE_USER_SERVICE_URL }} \
            --build-arg VITE_SCHEDULE_SERVICE_URL=${{ secrets.VITE_SCHEDULE_SERVICE_URL }} \
            --build-arg VITE_INTELLIGENCE_SERVICE_URL=${{ secrets.VITE_INTELLIGENCE_SERVICE_URL }} \
            --build-arg VITE_INSIGHT_SERVICE_URL=${{ secrets.VITE_INSIGHT_SERVICE_URL }} \
            --build-arg VITE_COGNITO_USER_POOL_ID=${{ secrets.VITE_COGNITO_USER_POOL_ID }} \
            --build-arg VITE_COGNITO_CLIENT_ID=${{ secrets.VITE_COGNITO_CLIENT_ID }} \
            --build-arg VITE_COGNITO_REGION=${{ secrets.VITE_COGNITO_REGION }} \
            --build-arg VITE_COGNITO_DOMAIN=${{ secrets.VITE_COGNITO_DOMAIN }} \
            --build-arg VITE_COGNITO_REDIRECT_URI=${{ secrets.VITE_COGNITO_REDIRECT_URI }} \
            -t $ECR_REGISTRY/planit-frontend:$IMAGE_TAG \
            ./PlanIt-FE
      
      - name: Push to ECR
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker push $ECR_REGISTRY/planit-frontend:$IMAGE_TAG
```

---

## 보안 주의사항

### ⚠️ 절대 하지 말아야 할 것
1. **Secret을 코드에 하드코딩하지 마세요**
   - ❌ `const API_KEY = "abc123"`
   - ✅ GitHub Secrets 사용

2. **Secret을 Git에 커밋하지 마세요**
   - ❌ `terraform.tfvars` 파일을 Git에 푸시
   - ✅ `.gitignore`에 추가

3. **Secret을 로그에 출력하지 마세요**
   - ❌ `echo ${{ secrets.AWS_SECRET_ACCESS_KEY }}`
   - ✅ 로그에 출력하지 않음

### ✅ 권장 사항
1. **Secret 값을 정기적으로 변경하세요**
   - JWT Secret: 6개월마다
   - DB Password: 3개월마다
   - AWS Access Key: 1년마다

2. **최소 권한 원칙을 따르세요**
   - AWS IAM 사용자에게 필요한 권한만 부여
   - Terraform 전용 IAM 사용자 생성 권장

3. **Secret 값을 안전하게 보관하세요**
   - 비밀번호 관리자 사용 (1Password, LastPass 등)
   - 팀원과 공유 시 암호화된 채널 사용

---

## 검증 방법

### 1. GitHub Actions 로그 확인
- Workflow 실행 후 로그에서 Secret이 `***`로 마스킹되는지 확인

### 2. Terraform Plan 확인
- `terraform plan` 실행 시 변수가 올바르게 주입되는지 확인

### 3. Frontend 빌드 확인
- Docker 이미지 빌드 시 환경 변수가 올바르게 주입되는지 확인

---

## 문제 해결

### Secret이 인식되지 않는 경우
1. Secret 이름이 정확한지 확인 (대소문자 구분)
2. Workflow 파일에서 `${{ secrets.SECRET_NAME }}` 형식으로 참조했는지 확인
3. Secret 값에 공백이나 특수문자가 있는지 확인

### Terraform 변수가 전달되지 않는 경우
1. `TF_VAR_` 접두사가 붙어있는지 확인
2. Workflow에서 `env:` 섹션에 변수를 선언했는지 확인

---

## 참고 자료
- [GitHub Actions Secrets 문서](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [Terraform Environment Variables](https://www.terraform.io/language/values/variables#environment-variables)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
