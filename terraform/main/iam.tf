resource "aws_iam_policy" "grafana_sns_publish" {
  name        = "GrafanaSNSPublishPolicy"
  path        = "/"
  description = "Allow Grafana/EKS Nodes to publish alerts to SNS topics"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = "arn:aws:sns:ap-northeast-2:935875533840:PI-DEV-alert-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nodes_sns_attach" {
  role       = "PI-DEV-EKS-Node-Role"
  policy_arn = aws_iam_policy.grafana_sns_publish.arn
}
