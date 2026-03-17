# ============================================
# Route53 Hosted Zone
# ============================================

resource "aws_route53_zone" "main" {
  count = var.create_route53_zone ? 1 : 0

  name = var.domain_name

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project_name}-${upper(var.environment)}-HostedZone"
    }
  )
}
