# Infrastructure DNS logging

resource "aws_cloudwatch_log_group" "dns_infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name              = "/aws/route53resolver/landing-zone/infrastructure"
  retention_in_days = var.dns_log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_resource_policy" "dns_infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  policy_name = "lz-infrastructure-dns-query-logs"

  policy_document = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowRoute53ResolverLogging"
        Effect = "Allow"

        Principal = {
          Service = "route53resolver.amazonaws.com"
        }

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.dns_infrastructure[0].arn}:*"

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.infrastructure.account_id
          }
        }
      }
    ]
  })
}

resource "aws_route53_resolver_query_log_config" "infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  name            = "lz-infrastructure-dns-query-logs"
  destination_arn = aws_cloudwatch_log_group.dns_infrastructure[0].arn

  tags = local.common_tags
}

resource "aws_route53_resolver_query_log_config_association" "infrastructure" {
  provider = aws.infrastructure

  count = var.enable_dns_security ? 1 : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.infrastructure[0].id
  resource_id                  = aws_vpc.infrastructure.id
}


# Production DNS logging

resource "aws_cloudwatch_log_group" "dns_production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name              = "/aws/route53resolver/landing-zone/production"
  retention_in_days = var.dns_log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_resource_policy" "dns_production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  policy_name = "lz-production-dns-query-logs"

  policy_document = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowRoute53ResolverLogging"
        Effect = "Allow"

        Principal = {
          Service = "route53resolver.amazonaws.com"
        }

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.dns_production[0].arn}:*"

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.production.account_id
          }
        }
      }
    ]
  })
}

resource "aws_route53_resolver_query_log_config" "production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  name            = "lz-production-dns-query-logs"
  destination_arn = aws_cloudwatch_log_group.dns_production[0].arn

  tags = local.common_tags
}

resource "aws_route53_resolver_query_log_config_association" "production" {
  provider = aws.production

  count = var.enable_dns_security ? 1 : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.production[0].id
  resource_id                  = aws_vpc.production.id
}



# Nonproduction DNS logging

resource "aws_cloudwatch_log_group" "dns_nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name              = "/aws/route53resolver/landing-zone/nonproduction"
  retention_in_days = var.dns_log_retention_days

  tags = local.common_tags
}

resource "aws_cloudwatch_log_resource_policy" "dns_nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  policy_name = "lz-nonproduction-dns-query-logs"

  policy_document = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowRoute53ResolverLogging"
        Effect = "Allow"

        Principal = {
          Service = "route53resolver.amazonaws.com"
        }

        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "${aws_cloudwatch_log_group.dns_nonproduction[0].arn}:*"

        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.nonproduction.account_id
          }
        }
      }
    ]
  })
}

resource "aws_route53_resolver_query_log_config" "nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  name            = "lz-nonproduction-dns-query-logs"
  destination_arn = aws_cloudwatch_log_group.dns_nonproduction[0].arn

  tags = local.common_tags
}

resource "aws_route53_resolver_query_log_config_association" "nonproduction" {
  provider = aws.nonproduction

  count = var.enable_dns_security ? 1 : 0

  resolver_query_log_config_id = aws_route53_resolver_query_log_config.nonproduction[0].id
  resource_id                  = aws_vpc.nonproduction.id
}
