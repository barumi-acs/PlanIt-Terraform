#admin_cidr       = "203.0.113.10/32"
admin_cidr                  = "0.0.0.0/0"
node_instance_types         = ["t3.medium"]
db_name                     = "planit_user_db"
db_username                 = "root"
db_password                 = "rootroot"
s3_bucket_name              = "pi-dev-bareunbaleum-s3-yeji-0317"
external_dns_domain_filters = ["8b5.shop"]

# ===== ACM & Route53 설정 =====
# Option 1: Terraform으로 ACM Certificate 생성
create_acm_certificate = true
create_route53_zone    = false  # 기존 Route53 Zone 사용
route53_zone_id        = "Z0120259141H6YIGJWR8P"  # 기존 Zone ID 입력

# Option 2: 기존 ACM Certificate 사용
# create_acm_certificate = false
# acm_certificate_arn = "arn:aws:acm:ap-northeast-2:YOUR_ACCOUNT_ID:certificate/YOUR_CERT_ID"

# ===== Cognito 설정 (본인 계정 정보로 변경) =====
cognito_user_pool_arn = "arn:aws:cognito-idp:ap-northeast-2:YOUR_ACCOUNT_ID:userpool/ap-northeast-2_GKpckavjT"
cognito_alb_client_id = "YOUR_COGNITO_ALB_CLIENT_ID"
cognito_domain        = "ap-northeast-2gkpckavjt.auth.ap-northeast-2.amazoncognito.com"


