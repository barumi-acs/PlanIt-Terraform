output "state_bucket_name" {
  description = "S3 bucket used for Terraform state"
  value       = aws_s3_bucket.tfstate.bucket
}

output "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  value       = aws_dynamodb_table.tf_lock.name
}

output "backend_config" {
  description = "Use this snippet in root backend configuration"
  value       = <<-EOT
  backend "s3" {
    bucket         = "${aws_s3_bucket.tfstate.bucket}"
    key            = "dev/terraform.tfstate"
    region         = "${var.aws_region}"
    dynamodb_table = "${aws_dynamodb_table.tf_lock.name}"
    encrypt        = true
  }
  EOT
}
