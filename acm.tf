# ============================================
# ACM Certificate
# ============================================

resource "aws_acm_certificate" "main" {
  count = var.create_acm_certificate ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${upper(var.environment)}-ACM-CERT"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Certificate Validation
resource "aws_route53_record" "cert_validation" {
  for_each = var.create_acm_certificate && var.create_route53_zone ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main[0].zone_id
}

# Certificate Validation Waiter
resource "aws_acm_certificate_validation" "main" {
  count = var.create_acm_certificate && var.create_route53_zone ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}
