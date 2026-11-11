
resource "aws_s3_bucket" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = "lz-central-dns-archive-${var.logging_account_id}-${var.primary_region}"

  # Object Lock must be enabled when the bucket is created.
  object_lock_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name      = "lz-central-dns-archive"
      Purpose   = "Central DNS audit archive"
      ManagedBy = "Terraform"
    }
  )
}

resource "aws_s3_bucket_public_access_block" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = var.dns_archive_retention_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.central_dns_archive
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  rule {
    id     = "central-dns-archive-retention"
    status = "Enabled"

    filter {
      prefix = "dns/"
    }

    transition {
      days          = var.dns_archive_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.dns_archive_retention_days
    }
  }

  depends_on = [
    aws_s3_bucket_versioning.central_dns_archive,
    aws_s3_bucket_object_lock_configuration.central_dns_archive
  ]
}


locals {
  dns_firehose_sources = {
    infrastructure = {
      account_id = var.infrastructure_account_id
      prefix     = "dns/infrastructure/*"
    }

    production = {
      account_id = var.production_account_id
      prefix     = "dns/production/*"
    }

    nonproduction = {
      account_id = var.nonproduction_account_id
      prefix     = "dns/nonproduction/*"
    }
  }
}

resource "aws_s3_bucket_policy" "central_dns_archive" {
  provider = aws.logging

  count = var.enable_dns_security ? 1 : 0

  bucket = aws_s3_bucket.central_dns_archive[0].id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = flatten([
      for name, source in local.dns_firehose_sources : [
        {
          Sid    = "Allow${name}FirehoseBucketAccess"
          Effect = "Allow"

          Principal = {
            AWS = "arn:aws:iam::${source.account_id}:root"
          }

          Action = [
            "s3:GetBucketLocation",
            "s3:ListBucket",
            "s3:ListBucketMultipartUploads"
          ]

          Resource = aws_s3_bucket.central_dns_archive[0].arn

          Condition = {
            ArnEquals = {
              "aws:PrincipalArn" = "arn:aws:iam::${source.account_id}:role/lz-dns-firehose-delivery"
            }
          }
        },
        {
          Sid    = "Allow${name}FirehoseObjectAccess"
          Effect = "Allow"

          Principal = {
            AWS = "arn:aws:iam::${source.account_id}:root"
          }

          Action = [
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:AbortMultipartUpload",
            "s3:ListMultipartUploadParts"
          ]

          Resource = "${aws_s3_bucket.central_dns_archive[0].arn}/${source.prefix}"

          Condition = {
            ArnEquals = {
              "aws:PrincipalArn" = "arn:aws:iam::${source.account_id}:role/lz-dns-firehose-delivery"
            }
          }
        }
      ]
    ])
  })

  depends_on = [
    aws_s3_bucket_public_access_block.central_dns_archive,
    aws_s3_bucket_ownership_controls.central_dns_archive
  ]
}
