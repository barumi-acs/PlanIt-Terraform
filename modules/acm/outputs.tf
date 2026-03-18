output "certificate_arn" {
  description = "ARN of the ACM certificate"
  value       = aws_acm_certificate.main.arn
}

output "certificate_domain" {
  description = "Domain name of the certificate"
  value       = aws_acm_certificate.main.domain_name
}

output "route53_zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.zone_id
}

output "route53_name_servers" {
  description = "Route53 name servers (if zone was created)"
  value       = var.create_route53_zone ? aws_route53_zone.main[0].name_servers : []
}
