# resource "aws_route53_zone" "this" {
#   name = var.domain_name
# }
#
# resource "aws_route53_record" "alb_alias" {
#   zone_id = aws_route53_zone.this.zone_id
#   name    = var.domain_name
#   type    = "A"
#
# }