
output "security_account_id" {
  description = "Central security account ID"
  value       = data.aws_caller_identity.security.account_id
}

output "management_account_id" {
  description = "Organizations management account ID"
  value       = data.aws_caller_identity.management.account_id
}

output "logging_account_id" {
  description = "Central logging account ID"
  value       = data.aws_caller_identity.logging.account_id
}

output "organization_id" {
  description = "AWS Organization ID"
  value       = data.aws_organizations_organization.current.id
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = try(aws_guardduty_detector.security[0].id, null)
}

output "securityhub_enabled" {
  description = "Whether Security Hub is enabled"
  value       = var.enable_securityhub
}

output "access_analyzer_arn" {
  description = "Organization Access Analyzer ARN"
  value       = try(aws_accessanalyzer_analyzer.organization[0].arn, null)
}

output "cloudtrail_arn" {
  description = "Organization CloudTrail ARN"
  value       = try(aws_cloudtrail.organization[0].arn, null)
}

output "audit_bucket_name" {
  description = "Centralized audit bucket name"
  value       = try(aws_s3_bucket.audit_logs[0].bucket, null)
}

output "config_aggregator_arn" {
  description = "AWS Config organization aggregator ARN"
  value       = try(aws_config_configuration_aggregator.organization[0].arn, null)
}
