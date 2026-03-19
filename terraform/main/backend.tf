# Terraform Backend 설정 (S3 + DynamoDB Lock)
# 
# 사용 방법:
# 1. 먼저 S3 버킷과 DynamoDB 테이블을 수동으로 생성해야 합니다
# 2. 생성 후 이 파일의 주석을 해제하고 terraform init -migrate-state 실행
#
# S3 버킷 생성 (AWS CLI):
#   aws s3api create-bucket \
#     --bucket planit-terraform-state-prod \
#     --region ap-northeast-2 \
#     --create-bucket-configuration LocationConstraint=ap-northeast-2
#
#   aws s3api put-bucket-versioning \
#     --bucket planit-terraform-state-prod \
#     --versioning-configuration Status=Enabled
#
#   aws s3api put-bucket-encryption \
#     --bucket planit-terraform-state-prod \
#     --server-side-encryption-configuration '{
#       "Rules": [{
#         "ApplyServerSideEncryptionByDefault": {
#           "SSEAlgorithm": "AES256"
#         }
#       }]
#     }'
#
# DynamoDB 테이블 생성 (AWS CLI):
#   aws dynamodb create-table \
#     --table-name planit-terraform-lock \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST \
#     --region ap-northeast-2

terraform {
	backend "s3" {
		bucket         = "planit-team-tfstate-bucket"
		key            = "dev/terraform.tfstate"
		region         = "ap-northeast-2"
		encrypt        = true
		dynamodb_table = "terraform-lock"
	}
}
