locals {
  ingress_yaml = templatefile("${path.module}/ingress-template.yaml", {
    namespace              = var.namespace
    domain_name            = var.domain_name
    certificate_arn        = var.acm_certificate_arn
    cognito_user_pool_arn  = var.cognito_user_pool_arn
    cognito_client_id      = var.cognito_alb_client_id
    cognito_domain         = var.cognito_domain
  })
}

resource "local_file" "ingress" {
  content  = local.ingress_yaml
  filename = "${path.root}/../PlanIt-Yaml/common/ingress.yaml"
}
