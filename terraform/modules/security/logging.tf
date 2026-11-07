
resource "aws_s3_bucket" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  bucket = "aws-landing-zone-audit-${var.logging_account_id}"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.audit_logs[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.audit_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.audit_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.audit_logs[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}
