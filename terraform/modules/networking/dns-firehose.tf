
# Infrastructure DNS archive delivery

module "dns_firehose_infrastructure" {
  count  = var.enable_dns_security ? 1 : 0
  source = "./dns-firehose"

  providers = {
    aws = aws.infrastructure
  }

  source_name           = "infrastructure"
  source_account_id     = var.infrastructure_account_id
  source_log_group_name = aws_cloudwatch_log_group.dns_infrastructure[0].name

  destination_bucket_arn = aws_s3_bucket.central_dns_archive[0].arn
  destination_prefix     = "dns/infrastructure/"

  common_tags = local.common_tags

  depends_on = [
    aws_s3_bucket_policy.central_dns_archive
  ]
}

# Production DNS archive delivery

module "dns_firehose_production" {
  count  = var.enable_dns_security ? 1 : 0
  source = "./dns-firehose"

  providers = {
    aws = aws.production
  }

  source_name           = "production"
  source_account_id     = var.production_account_id
  source_log_group_name = aws_cloudwatch_log_group.dns_production[0].name

  destination_bucket_arn = aws_s3_bucket.central_dns_archive[0].arn
  destination_prefix     = "dns/production/"

  common_tags = local.common_tags

  depends_on = [
    aws_s3_bucket_policy.central_dns_archive
  ]
}

# NonProduction DNS archive delivery

module "dns_firehose_nonproduction" {
  count  = var.enable_dns_security ? 1 : 0
  source = "./dns-firehose"

  providers = {
    aws = aws.nonproduction
  }

  source_name           = "nonproduction"
  source_account_id     = var.nonproduction_account_id
  source_log_group_name = aws_cloudwatch_log_group.dns_nonproduction[0].name

  destination_bucket_arn = aws_s3_bucket.central_dns_archive[0].arn
  destination_prefix     = "dns/nonproduction/"

  common_tags = local.common_tags

  depends_on = [
    aws_s3_bucket_policy.central_dns_archive
  ]
}
