# Secrets Manager 설정 가이드

## 1. Terraform 변수 설정

`environments/dev-secrets.tfvars` 파일 생성:

```bash
cd PlanIt-Terraform
cp environments/dev-secrets.tfvars.example environments/dev-secrets.tfvars
```

실제 값으로 편집:
- DB 비밀번호
- AWS Access Key/Secret Key
- Cognito Client Secret
- JWT Secret
- GNews API Key

## 2. Terraform 적용

```bash
terraform init
terraform plan -var-file=environments/dev.tfvars -var-file=environments/dev-secrets.tfvars
terraform apply -var-file=environments/dev.tfvars -var-file=environments/dev-secrets.tfvars
```

## 3. ServiceAccount ARN 업데이트

```bash
# IRSA Role ARN 확인
terraform output secrets_irsa_role_arn

# 출력된 ARN을 복사하여 PlanIt-Yaml/common/service-account.yaml 파일 수정
```

## 4. Kubernetes 배포

PlanIt-Yaml/README.md 참고하여 순서대로 배포

## 보안 체크리스트

- [ ] dev-secrets.tfvars 파일이 .gitignore에 포함되어 있는지 확인
- [ ] 기존 하드코딩된 비밀번호/키가 모두 제거되었는지 확인
- [ ] AWS Secrets Manager에 시크릿이 생성되었는지 확인
- [ ] IRSA Role이 올바르게 설정되었는지 확인
- [ ] CSI Driver가 설치되었는지 확인
- [ ] ACM Certificate가 검증되었는지 확인 (ISSUED 상태)
- [ ] Cognito ALB Client가 생성되고 Callback URL이 설정되었는지 확인

