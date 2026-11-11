
resource "aws_cloudtrail" "organization" {
  provider = aws.management

  count = var.enable_cloudtrail ? 1 : 0

  name                          = var.cloudtrail_name
  s3_bucket_name                = aws_s3_bucket.audit_logs[0].bucket
  s3_key_prefix                 = "cloudtrail"
  is_organization_trail         = true
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true

  depends_on = [
    aws_s3_bucket_policy.audit_logs
  ]

  tags = local.common_tags
}



data "aws_iam_policy_document" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl"
    ]

    resources = [
      aws_s3_bucket.audit_logs[0].arn
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudtrail:${var.primary_region}:${var.management_account_id}:trail/${var.cloudtrail_name}"
      ]
    }
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.audit_logs[0].arn}/cloudtrail/AWSLogs/${var.organization_id}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"

      values = [
        "arn:aws:cloudtrail:${var.primary_region}:${var.management_account_id}:trail/${var.cloudtrail_name}"
      ]
    }
  }
}

# Cloudtrail bucket policy
resource "aws_s3_bucket_policy" "audit_logs" {
  provider = aws.logging

  count = var.enable_cloudtrail ? 1 : 0

  bucket = aws_s3_bucket.audit_logs[0].id
  policy = data.aws_iam_policy_document.audit_logs[0].json

  depends_on = [
    aws_s3_bucket_public_access_block.audit_logs
  ]
}
