# 호스팅 영역 생성
resource "aws_route53_zone" "vec_prd_hosted_zone" {
  name = "8b5.shop"
}
