
# ==========================================================
# DATA SOURCES
# ==========================================================

data "aws_partition" "current" {}

# ==========================================================
# AWS CONTROL TOWER ADMIN ROLE
# ==========================================================

resource "aws_iam_role" "control_tower_admin" {
  name = "AWSControlTowerAdmin"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "controltower.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "AWS Control Tower Administration"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# AWS Managed Policy
resource "aws_iam_role_policy_attachment" "control_tower_admin" {
  role = aws_iam_role.control_tower_admin.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSControlTowerServiceRolePolicy"
}

# Inline Policy
resource "aws_iam_role_policy" "control_tower_admin" {
  name = "AWSControlTowerAdminPolicy"
  role = aws_iam_role.control_tower_admin.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeAvailabilityZones"
        ]

        Resource = "*"
      }
    ]
  })
}

# ==========================================================
# AWS CONTROL TOWER CLOUDTRAIL ROLE
# ==========================================================

resource "aws_iam_role" "control_tower_cloudtrail" {
  name = "AWSControlTowerCloudTrailRole"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "AWS Control Tower CloudTrail"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# AWS Managed Policy
resource "aws_iam_role_policy_attachment" "control_tower_cloudtrail" {
  role = aws_iam_role.control_tower_cloudtrail.name

  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AWSControlTowerCloudTrailRolePolicy"
}

# ==========================================================
# AWS CONTROL TOWER STACKSET ROLE
# ==========================================================

resource "aws_iam_role" "control_tower_stackset" {
  name = "AWSControlTowerStackSetRole"
  path = "/service-role/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "cloudformation.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "AWS Control Tower StackSets"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Inline Policy
resource "aws_iam_role_policy" "control_tower_stackset" {
  name = "AWSControlTowerStackSetRolePolicy"
  role = aws_iam_role.control_tower_stackset.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sts:AssumeRole"
        ]

        Resource = [
          "arn:${data.aws_partition.current.partition}:iam::*:role/AWSControlTowerExecution"
        ]
      }
    ]
  })
}
