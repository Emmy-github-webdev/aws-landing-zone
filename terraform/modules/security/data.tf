data "aws_caller_identity" "security" {}

data "aws_caller_identity" "management" {
  provider = aws.management
}

data "aws_caller_identity" "logging" {
  provider = aws.logging
}

data "aws_organizations_organization" "current" {
  provider = aws.management
}

data "aws_region" "current" {}


# Cloudtral bucket policy

data "aws_iam_policy_document" "cloudtrail_bucket" {
  # Allow CloudTrail to check bucket permissions
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

  # Allow CloudTrail to write organization logs
  statement {
    sid    = "AWSCloudTrailOrganizationWrite"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.audit_logs[0].arn}/AWSLogs/${var.organization_id}/*"
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
