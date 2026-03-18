# AWS Secrets Manager Secret
resource "aws_secretsmanager_secret" "app_config" {
  name        = "planit/dev/app-config"
  description = "PlanIt application configuration secrets"

  tags = {
    Name        = "${var.project_name}-App-Config"
    Environment = "dev"
  }
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    DB_USERNAME           = var.db_username
    DB_PASSWORD           = var.db_password
    AWS_ACCESS_KEY_ID     = var.aws_access_key_id
    AWS_SECRET_ACCESS_KEY = var.aws_secret_access_key
    COGNITO_CLIENT_SECRET = var.cognito_client_secret
    JWT_SECRET            = var.jwt_secret
    GNEWS_API_KEY         = var.gnews_api_key
  })
}

# IRSA for Secrets Manager access
data "aws_iam_policy_document" "secrets_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer}:sub"
      values   = ["system:serviceaccount:planit-dev:planit-app-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "secrets_access" {
  statement {
    sid    = "AllowSecretsManagerRead"
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [aws_secretsmanager_secret.app_config.arn]
  }
}

resource "aws_iam_policy" "secrets_access" {
  name   = "${var.project_name}-Secrets-Access-Policy"
  policy = data.aws_iam_policy_document.secrets_access.json

  tags = {
    Name = "${var.project_name}-Secrets-Access-Policy"
  }
}

resource "aws_iam_role" "secrets_access" {
  name               = "${var.project_name}-Secrets-Access-Role"
  assume_role_policy = data.aws_iam_policy_document.secrets_assume_role.json

  tags = {
    Name = "${var.project_name}-Secrets-Access-Role"
  }
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
  role       = aws_iam_role.secrets_access.name
  policy_arn = aws_iam_policy.secrets_access.arn
}
