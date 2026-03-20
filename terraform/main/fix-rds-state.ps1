Write-Host "=== RDS Terraform State 수정 시작 ===" -ForegroundColor Green

# 1. 기존 RDS 모듈의 리소스를 State에서 제거
Write-Host "`n1. 기존 RDS 모듈 리소스 제거 중..." -ForegroundColor Yellow
terraform state rm module.rds_user.aws_db_subnet_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_user subnet group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_user.aws_db_parameter_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_user parameter group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_schedule.aws_db_subnet_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_schedule subnet group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_schedule.aws_db_parameter_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_schedule parameter group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_strategy.aws_db_subnet_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_strategy subnet group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_strategy.aws_db_parameter_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_strategy parameter group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_insight.aws_db_subnet_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_insight subnet group 없음 (정상)" -ForegroundColor Gray }

terraform state rm module.rds_insight.aws_db_parameter_group.this 2>$null
if ($LASTEXITCODE -ne 0) { Write-Host "  - rds_insight parameter group 없음 (정상)" -ForegroundColor Gray }

# 2. 기존 AWS 리소스를 새로운 공유 리소스로 import
Write-Host "`n2. 기존 AWS 리소스를 새로운 공유 리소스로 import 중..." -ForegroundColor Yellow
Write-Host "  - DB Subnet Group import 중..." -ForegroundColor Cyan
terraform import aws_db_subnet_group.shared pi-dev-db-subnet-group

Write-Host "  - DB Parameter Group import 중..." -ForegroundColor Cyan
terraform import aws_db_parameter_group.shared pi-dev-mariadb-params

# 3. Plan 확인
Write-Host "`n3. Terraform Plan 확인 중..." -ForegroundColor Yellow
terraform plan

Write-Host "`n=== RDS Terraform State 수정 완료 ===" -ForegroundColor Green
Write-Host "이제 'terraform apply'를 실행하여 4개의 RDS 인스턴스를 생성하세요." -ForegroundColor Cyan
