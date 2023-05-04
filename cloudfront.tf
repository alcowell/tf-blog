resource "aws_cloudfront_distribution" "s3_distribution" {
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.yosuk-blog.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.yosuk-blog.id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.yosuk-blog.id
    viewer_protocol_policy = "redirect-to-https"
    cached_methods         = ["GET", "HEAD"]
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.path_rewrite.arn
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations = [
        "JP",
      ]
    }
  }
  aliases = [
    "alcowell.net",
  ]
  custom_error_response {
    error_code         = 403
    response_code      = 204
    response_page_path = "/index.html"
  }
}

resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = "cf-oac-yosuk-blog"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_function" "path_rewrite" {
  name    = "path_rewrite"
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = file("./function.js")
}
