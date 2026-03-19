resource "aws_cloudfront_origin_access_control" "this" {
  name                              = "${var.project_name}-oac"
  description                       = "OAC for frontend S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true

  # 🚨 팩트: 이게 있어야 '대체 도메인 이름'에 네 주소가 떠!
  aliases = var.aliases

  origin {
    domain_name = var.bucket_domain_name
    origin_id   = "s3-origin"

    origin_access_control_id = aws_cloudfront_origin_access_control.this.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  default_root_object = "index.html"

  # 🔥 SPA 필수 설정
  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    # 🚨 팩트: 도메인을 쓰려면 AWS 인증서(ACM)가 반드시 연결되어야 해
    acm_certificate_arn      = trimspace(var.acm_certificate_arn_SEOUL) # 🚨 팩트: 서울 리전 인증서 ARN 사용
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}