# ============================================
# S3 Buckets
# ============================================

resource "aws_s3_bucket" "main" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = var.s3_bucket_name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${upper(var.environment)}-S3"
    }
  )
}

# S3 Bucket Versioning (Optional)
resource "aws_s3_bucket_versioning" "main" {
  count = var.create_s3_bucket && var.enable_s3_versioning ? 1 : 0

  bucket = aws_s3_bucket.main[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Encryption (Optional)
resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  count = var.create_s3_bucket && var.enable_s3_encryption ? 1 : 0

  bucket = aws_s3_bucket.main[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block (Recommended)
resource "aws_s3_bucket_public_access_block" "main" {
  count = var.create_s3_bucket ? 1 : 0

  bucket = aws_s3_bucket.main[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
