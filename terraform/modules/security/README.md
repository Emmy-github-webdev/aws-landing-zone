# Security module

The security module deploys centralized security and audit services for the
landing zone. The environment wrapper instantiates it in a primary and
secondary AWS Region, using the Security account for security services and the
Logging account for the CloudTrail destination bucket.

The module validates the active Security, Management, and Logging account IDs
and the AWS Organization before deploying. A failed validation stops the
deployment rather than proceeding in an unexpected account or organization.

## What the environment deploys

| Service / resource | Primary Region | Secondary Region | Behavior |
| --- | --- | --- | --- |
| GuardDuty | Enabled | Enabled | Creates a detector, publishes findings every 15 minutes, enables organization membership for all accounts, and auto-enables S3 data events for all members. |
| Security Hub | Enabled | Enabled | Enables Security Hub and organization auto-enrollment. Default standards are disabled; the module does not select a standards pack. |
| IAM Access Analyzer | Enabled | Enabled | Creates an organization-level analyzer in each Region. |
| Organization CloudTrail | Enabled | Disabled | Creates a multi-Region organization trail with global service events and log-file validation. |
| CloudTrail S3 destination | Enabled | Disabled | Creates the bucket in the Logging account with versioning, AES256 server-side encryption, public-access blocking, and bucket ownership controls. |
| AWS Config organization aggregator | Enabled | Disabled | Creates an aggregator in the Security account configured to aggregate all Regions using `config_aggregator_role_arn`. |

This module creates an AWS Config aggregator, not Config recorders, delivery
channels, or Config rules. Those must be established separately for the
aggregator to receive account and resource configuration data.

Organization integration is configured by the environment wrapper in
[`terraform/environments/security/delegated-admin.tf`](../../environments/security/delegated-admin.tf):
it registers Security Hub in both Regions and enables trusted access and
delegated administration for IAM Access Analyzer and AWS Config. The GuardDuty
delegated-administrator resources in that file are commented out; verify the
organization's GuardDuty administration setup before relying on organization
auto-enrollment.

## Account and provider layout

| Provider | Account / purpose |
| --- | --- |
| Default `aws` | Assumes the Security account role; creates regional detectors, analyzers, Security Hub resources, and the Config aggregator. |
| `aws.management` | Uses the Management account credentials for organization identity and delegated-administrator operations. |
| `aws.logging` | Assumes the Logging account role; creates the CloudTrail log bucket and bucket policy in the primary Region. |
| `aws.secondary` (environment wrapper) | Assumes the Security account role in the secondary Region. |

The module's `terraform_data.account_validation` preconditions compare the
provider identities with the configured Security, Management, and Logging
account IDs, and verify that the expected Management account owns the
organization. Do not remove these checks without replacing their deployment
safeguards.

## Module inputs

| Input | Type | Default / validation | Purpose and current use |
| --- | --- | --- | --- |
| `organization_id` | `string` | Required | Expected AWS Organization ID; checked against the Management provider. |
| `management_account_id` | `string` | Required | Expected Management account ID; checked against the Management provider and Organization. |
| `security_account_id` | `string` | Required | Expected Security account ID; checked against the default provider and Config aggregator role. |
| `logging_account_id` | `string` | Required | Expected Logging account ID; checked against the Logging provider. |
| `primary_region` | `string` | Required | Primary Region used for the centralized CloudTrail. |
| `approved_regions` | `list(string)` | Required; must not be empty | Validated as non-empty, but does not select Regions or configure services. The environment wrapper explicitly instantiates the module in the primary and secondary Regions. |
| `config_aggregator_role_arn` | `string` | Required; must match an IAM role ARN format and belong to the Security account | Role ARN supplied to the AWS Config organization aggregator. It is required even when aggregation is disabled. |
| `environment` | `string` | `"production"` | Environment value included in common resource tags. |
| `cloudtrail_name` | `string` | `"organization-cloudtrail"` | Name of the organization trail. |
| `cloudtrail_retention_days` | `number` | `365` | Declared input, but not currently used to configure S3 lifecycle expiration or CloudTrail retention. |
| `config_aggregator_name` | `string` | `"organization-config-aggregator"` | Name of the Config aggregator. |
| `enable_cloudtrail` | `bool` | `false` | Creates the organization trail, its S3 bucket, and related bucket configuration when true. |
| `enable_config_aggregator` | `bool` | `false` | Enables aggregator creation only when `enable_config` is also true. |
| `enable_guardduty` | `bool` | `true` | Creates the regional GuardDuty detector and organization configuration. |
| `enable_securityhub` | `bool` | `true` | Creates the regional Security Hub account and organization configuration. |
| `enable_access_analyzer` | `bool` | `true` | Creates a regional organization-level Access Analyzer. |
| `enable_config` | `bool` | `true` | Must be true along with `enable_config_aggregator` to create the aggregator. |
| `policy_tags` | `map(string)` | Required | Merged with the `environment`, `ManagedBy`, and `Organization` tags. |

The regional feature flags default to enabled in the module, but the
environment wrapper sets them explicitly. When changing that wrapper, keep
CloudTrail and the Config aggregator in the intended Region rather than
enabling them in every module instance.

## Outputs

The module exports its observed Security, Management, Logging, and Organization
IDs. It also exports the GuardDuty detector ID, Security Hub enabled flag,
Access Analyzer ARN, CloudTrail ARN, audit bucket name, and Config aggregator
ARN. Outputs for conditionally disabled resources are `null`.

The environment wrapper exposes primary and secondary GuardDuty detector IDs
and Access Analyzer ARNs, plus the primary audit bucket name, CloudTrail ARN,
and Config aggregator ARN.

## Audit log bucket protections and retention

The audit bucket is versioned, encrypted with SSE-S3 (`AES256`), protected by
S3 Block Public Access, and configured with bucket ownership controls. The
bucket policy permits CloudTrail to check bucket permissions and deliver
management-account and organization logs.

The bucket currently has `prevent_destroy = false` for testing. Review and
change this before production use if Terraform must not destroy the audit-log
bucket. Also note that `cloudtrail_retention_days` currently has no effect:
there is no lifecycle rule to expire log objects or noncurrent object
versions.

## Terraform files

| File | Responsibility |
| --- | --- |
| [`main.tf`](./main.tf) | Validates account and organization identities. |
| [`cloudtrail.tf`](./cloudtrail.tf) | Defines the organization trail and its S3 bucket policy. |
| [`logging.tf`](./logging.tf) | Defines the CloudTrail destination bucket and its protections. |
| [`guardduty.tf`](./guardduty.tf) | Defines GuardDuty detector and organization configuration. |
| [`securityhub.tf`](./securityhub.tf) | Defines Security Hub account and organization configuration. |
| [`access-analyzer.tf`](./access-analyzer.tf) | Defines the organization-level Access Analyzer. |
| [`config.tf`](./config.tf) | Defines the organization Config aggregator. |
| [`data.tf`](./data.tf) | Reads caller identities, organization, and current Region. |
| [`locals.tf`](./locals.tf) | Builds common tags and helper values. |
| [`variables.tf`](./variables.tf) | Declares module inputs and validation. |
| [`outputs.tf`](./outputs.tf) | Exposes account IDs and created resource identifiers. |
| [`versions.tf`](./versions.tf) | Declares provider aliases required by the module. |

## Deployment

The environment wrapper is [`terraform/environments/security`](../../environments/security/).
It reads the Organizations state for the Management account ID, configures
provider roles for the three accounts, and deploys the module in the primary
and secondary Regions. Its remote state key is
`landing-zone/security/terraform.tfstate`.

The GitHub Actions workflow is
[`security.yml`](../../../.github/workflows/security.yml). Its current module
and environment path filters omit the repository's `terraform/` directory, so
changes to those files alone do not trigger it. See the
[workflow documentation](../../../.github/workflows/README.md) before relying
on automatic runs. Before applying:

1. Verify the execution credentials and role ARNs target the intended
   Management, Security, and Logging accounts.
2. Confirm the organization ID, account IDs, Regions, and Config aggregator
   role ARN.
3. Review the plan to ensure CloudTrail and the Config aggregator are created
   only in the primary Region.
4. Confirm delegated administrators and trusted service access are configured
   for each organization-integrated service.
5. Confirm CloudTrail log retention and deletion protection meet the
   environment's operational requirements.
