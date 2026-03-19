output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.app_config.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.app_config.name
}

output "irsa_role_arn" {
  description = "ARN of the IRSA role for secrets access"
  value       = aws_iam_role.secrets_access.arn
}

output "irsa_role_name" {
  description = "Name of the IRSA role for secrets access"
  value       = aws_iam_role.secrets_access.name
}
