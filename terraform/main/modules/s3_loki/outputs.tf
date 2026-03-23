output "bucket_name" {
  description = "생성된 S3 버킷 이름"
  value       = aws_s3_bucket.loki.id
}

output "bucket_arn" {
  description = "생성된 S3 버킷 ARN"
  value       = aws_s3_bucket.loki.arn
}

output "bucket_region" {
  description = "S3 버킷 리전"
  value       = aws_s3_bucket.loki.region
}
