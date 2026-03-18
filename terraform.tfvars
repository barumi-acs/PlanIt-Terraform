#admin_cidr       = "203.0.113.10/32"
admin_cidr                  = "0.0.0.0/0"
node_instance_types         = ["t3.medium"]
db_name                     = "planit_user_db"
db_username                 = "root"
db_password                 = "rootroot"
s3_bucket_name              = "pi-dev-bareunbaleum-s3-unique-suffix"
external_dns_domain_filters = ["barumi-planit.store"]

# Cognito 설정
cognito_user_pool_id = "ap-northeast-2_GKpckavjT"
cognito_client_id    = "6j5ajq8p3b7d894qt5msp4hair"

# JWT Secret (최소 32자 이상 필수)
jwt_secret = "planit-production-jwt-secret-key-change-this-to-secure-random-string-2024"

# ACM 인증서 ARN (HTTPS용)
acm_certificate_arn = "arn:aws:acm:ap-northeast-2:935875533840:certificate/a047598e-c697-443d-a037-d051f2ef733e"
