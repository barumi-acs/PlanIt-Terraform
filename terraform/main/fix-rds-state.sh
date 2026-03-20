#!/bin/bash

echo "=== RDS Terraform State 수정 시작 ==="

# 1. 기존 RDS 모듈의 리소스를 State에서 제거
echo "1. 기존 RDS 모듈 리소스 제거 중..."
terraform state rm module.rds_user.aws_db_subnet_group.this 2>/dev/null || echo "  - rds_user subnet group 없음 (정상)"
terraform state rm module.rds_user.aws_db_parameter_group.this 2>/dev/null || echo "  - rds_user parameter group 없음 (정상)"
terraform state rm module.rds_schedule.aws_db_subnet_group.this 2>/dev/null || echo "  - rds_schedule subnet group 없음 (정상)"
terraform state rm module.rds_schedule.aws_db_parameter_group.this 2>/dev/null || echo "  - rds_schedule parameter group 없음 (정상)"
terraform state rm module.rds_strategy.aws_db_subnet_group.this 2>/dev/null || echo "  - rds_strategy subnet group 없음 (정상)"
terraform state rm module.rds_strategy.aws_db_parameter_group.this 2>/dev/null || echo "  - rds_strategy parameter group 없음 (정상)"
terraform state rm module.rds_insight.aws_db_subnet_group.this 2>/dev/null || echo "  - rds_insight subnet group 없음 (정상)"
terraform state rm module.rds_insight.aws_db_parameter_group.this 2>/dev/null || echo "  - rds_insight parameter group 없음 (정상)"

echo ""
echo "2. 기존 AWS 리소스를 새로운 공유 리소스로 import 중..."
terraform import aws_db_subnet_group.shared pi-dev-db-subnet-group
terraform import aws_db_parameter_group.shared pi-dev-mariadb-params

echo ""
echo "3. Terraform Plan 확인 중..."
terraform plan

echo ""
echo "=== RDS Terraform State 수정 완료 ==="
echo "이제 'terraform apply'를 실행하여 4개의 RDS 인스턴스를 생성하세요."
