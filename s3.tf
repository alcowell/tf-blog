
resource "aws_s3_bucket" "yosuk-blog" {
  bucket        = "yosuk-blog"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "website_conf" {
  bucket = aws_s3_bucket.yosuk-blog.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "404.html"
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.yosuk-blog.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}

resource "aws_s3_bucket_public_access_block" "public_access_conf" {
  bucket                  = aws_s3_bucket.yosuk-blog.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.yosuk-blog.arn}/*",
    ]
    principals {
      type = "Service"
      identifiers = [
        "cloudfront.amazonaws.com",
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values = [
        "${aws_cloudfront_distribution.s3_distribution.arn}",
      ]
    }
  }
}
