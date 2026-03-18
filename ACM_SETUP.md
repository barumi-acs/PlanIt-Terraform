# ACM Certificate 설정 가이드

## Option 1: Terraform으로 ACM 생성 (권장)

### 1. Route53 Hosted Zone 확인

기존 Route53 Zone이 있는 경우:
```bash
aws route53 list-hosted-zones
```

Zone ID를 복사하여 `terraform.tfvars`에 설정:
```hcl
create_acm_certificate = true
create_route53_zone    = false
route53_zone_id        = "Z1234567890ABC"  # 실제 Zone ID
```

새로 생성하는 경우:
```hcl
create_acm_certificate = true
create_route53_zone    = true
```

### 2. Terraform 적용

```bash
terraform apply -var-file=terraform.tfvars -var-file=environments/dev-secrets.tfvars
```

### 3. Name Server 설정 (새 Zone 생성 시)

```bash
terraform output route53_name_servers
```

출력된 Name Server를 도메인 등록 업체에 설정

### 4. Certificate 검증 대기

DNS 전파 후 자동으로 검증됩니다 (보통 5-10분 소요)

## Option 2: 기존 ACM Certificate 사용

이미 ACM Certificate가 있는 경우:

```hcl
create_acm_certificate = false
acm_certificate_arn    = "arn:aws:acm:ap-northeast-2:123456789012:certificate/abc-123"
```

## Cognito 설정

### ALB 인증용 Cognito Client 생성

1. Cognito User Pool 콘솔 접속
2. App Integration > App clients 메뉴
3. "Create app client" 클릭
4. 설정:
   - App type: Public client
   - App client name: planit-alb-client
   - Authentication flows: ALLOW_USER_SRP_AUTH
   - OAuth 2.0 grant types: Authorization code grant
   - OpenID Connect scopes: openid, email, phone
   - Callback URLs: https://YOUR_DOMAIN/oauth2/idpresponse
   - Sign out URLs: https://YOUR_DOMAIN/

5. Client ID를 복사하여 `terraform.tfvars`에 설정:
```hcl
cognito_alb_client_id = "복사한_CLIENT_ID"
```

### User Pool ARN 확인

```bash
aws cognito-idp describe-user-pool --user-pool-id ap-northeast-2_GKpckavjT
```

ARN을 복사하여 `terraform.tfvars`에 설정

## 검증

```bash
# Certificate 상태 확인
aws acm describe-certificate --certificate-arn $(terraform output -raw acm_certificate_arn)

# Ingress 확인
kubectl get ingress -n planit-dev
```
