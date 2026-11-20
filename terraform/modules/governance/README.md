# Governance module

The governance module manages preventive AWS Organizations controls for this
landing zone. It currently creates two Service Control Policies (SCPs) and
attaches them to the organization root and Workloads OU. Other controls in this
document are candidates for future implementation; they are not deployed by
this module today.

## Current controls

| SCP | Effect | Attachment | Current behavior |
| --- | --- | --- | --- |
| `DenyLeavingOrganization` | Denies `organizations:LeaveOrganization` | Organization root | Prevents member accounts from leaving the organization. |
| `DenyUnapprovedRegions` | Denies non-exempt actions outside the allowed Regions | Workloads OU | Denies actions outside `us-east-1` and `us-west-2`; actions listed in `NotAction` are exempt from this regional deny. Production and NonProduction inherit this policy through the OU hierarchy. |

The region policy is currently hard-coded in
[`policies/region_restriction_policy.json`](./policies/region_restriction_policy.json).
Although Terraform accepts and passes the `approved_regions` input, the policy
file does not interpolate it yet. Changing that input alone therefore does not
change the deployed region list.

SCPs set the maximum permissions available to identities in attached member
accounts; they do not grant permissions. An SCP also does not restrict the
organization's management account. Validate the effects of any new deny
statement against account recovery, deployment, and security operations before
attaching it broadly.

## Terraform resources and files

| File | Responsibility |
| --- | --- |
| [`main.tf`](./main.tf) | Defines the two SCPs, their attachments, and the `organization_id` output. |
| [`local.tf`](./local.tf) | Loads the policy documents and compares the current organization ID with the expected ID. |
| [`data.tf`](./data.tf) | Reads the active AWS Organization. |
| [`variables.tf`](./variables.tf) | Declares module inputs. |
| [`policies/`](./policies/) | Contains the JSON policy documents. |

Both policy resources have a Terraform precondition that stops creation when
the active organization ID does not match `organization_id`. The output also
checks this value.

## Module inputs

All inputs below are required; the module does not set defaults.

| Input | Type | Purpose / current use |
| --- | --- | --- |
| `organization_id` | `string` | Expected AWS Organization ID; checked before policy creation. |
| `organization_root_id` | `string` | Organization root ID; target for the organization-protection SCP. |
| `workloads_ou_id` | `string` | OU ID; target for the region-restriction SCP. |
| `approved_regions` | `list(string)` | Intended region allow-list. The current policy JSON does not yet use this value; see [Current controls](#current-controls). |
| `policy_tags` | `map(string)` | Tags applied to the two SCP resources. |
| `infrastructure_ou_id` | `string` | Declared for the governance configuration but not currently used by a resource. |
| `production_ou_id` | `string` | Declared for the governance configuration but not currently used by a resource. |
| `nonproduction_ou_id` | `string` | Declared for the governance configuration but not currently used by a resource. |
| `sandbox_ou_id` | `string` | Declared for the governance configuration but not currently used by a resource. |

## Deployment

The environment wrapper is [`terraform/environments/governance`](../../environments/governance/).
It supplies organization and OU identifiers, approved-region configuration,
and common tags to this module. The GitHub Actions workflow runs Terraform for
changes to the governance module or environment; see
[`governance.yml`](../../../.github/workflows/governance.yml).

Before deploying:

1. Verify the AWS credentials and Terraform execution role target the intended
   management account and organization.
2. Confirm `expected_organization_id` and `organization_root_id` are correct.
3. Review the plan, paying particular attention to root-level SCP attachments
   and their impact on member accounts.
4. Remember that changing `approved_regions` currently does not update the
   region policy document; edit the policy JSON until it is parameterized.

## Candidate governance roadmap

The following controls are drawn from the repository's policy inventory. They
are proposals, not resources currently managed by this module. Implement them
incrementally, beginning with high-impact guardrails and validating service
exceptions and recovery paths before broad attachment.

### Organization and region guardrails

- Protect organization configuration, account membership, OU structure,
  trusted service access, and delegated administrator registrations.
- Parameterize the approved-region policy and account for global services
  such as IAM, Route 53, and CloudFront.
- Restrict unauthorized region opt-in changes where appropriate.

### Identity and access management

- Prevent root access-key creation and protect administrator roles and IAM
  policies from unauthorized changes.
- Reduce IAM user creation and long-lived access keys; prefer IAM Identity
  Center and short-lived role sessions.
- Protect MFA controls and service-linked roles.

### Audit, logging, and security monitoring

- Prevent disabling, stopping, or deleting CloudTrail and AWS Config recording.
- Protect central audit-log buckets, their policies, and CloudWatch log groups.
- Expand centralized AWS Config, Security Hub, GuardDuty, and related
  monitoring coverage.

### Data protection

- Protect S3 Block Public Access settings and restrict risky bucket changes.
- Require supported encryption configurations for S3, EBS, and RDS, and
  protect KMS keys and secrets from unauthorized disabling or deletion.
- Restrict snapshot sharing and other paths that could expose data externally.
- Pair preventive controls with detective checks: an SCP cannot enforce every
  service configuration or detect existing noncompliant resources.

### Network and workload security

- Protect VPCs, security groups, default security groups, flow logs, and
  centralized connectivity resources from unauthorized changes.
- Consider controls for public IP assignment, internet gateways, VPC peering,
  and Transit Gateway changes.
- Evaluate workload guardrails for EC2 instance types, IMDSv2, public AMIs,
  Lambda runtimes, EKS endpoint exposure, and snapshot sharing.

### Cost governance

- Consider restrictions for expensive instance families, GPU instances,
  Regions, services, and Marketplace subscriptions.
- Use AWS Budgets, Cost Anomaly Detection, and Cost Explorer alongside any
  preventive restrictions.

## Use the right control type

Not every governance requirement belongs in an SCP. Choose the policy or
service that can enforce and report the desired behavior:

| Control type | Best suited for | Examples to evaluate |
| --- | --- | --- |
| SCP | Maximum permissions for identities in member accounts | Organization protection, region restrictions, IAM and logging protection |
| Resource Control Policy (RCP) | Limits on access to supported resources, including access by external identities | Restrict external access to sensitive S3 resources; require secure transport where supported |
| Declarative policy | Centrally enforcing AWS-supported service configurations | EBS encryption, public-access restrictions, root-user settings, backup configuration |
| Tag policy | Standardizing tag keys and allowed values | Required organizational tag conventions |
| Backup policy | Centrally standardizing backup plans | Backup schedules, retention, and supported resource assignments |
| AWS Config and other detective controls | Detecting existing or newly created noncompliant resources | Public S3 access, missing encryption, open SSH, missing CloudTrail or VPC Flow Logs |
| Cost-management services | Budgets, trends, and anomaly detection | Budgets, Cost Anomaly Detection, and Cost Explorer |

RCP and declarative-policy support varies by AWS service and feature. Confirm
current AWS Organizations support and test the policy type before adopting it.
For example, AWS Config rules can detect a condition but do not by themselves
prevent it.

## Suggested implementation order

1. Complete and test organization and region guardrails.
2. Protect CloudTrail, AWS Config, and central audit logs.
3. Protect root credentials and reduce IAM privilege-escalation paths.
4. Add S3 public-access, encryption, and KMS protections, with detective
   coverage for configurations SCPs cannot enforce.
5. Add external-access controls using RCPs where supported.
6. Adopt tag and backup policies, then network, workload, and cost controls.
7. Centralize security monitoring and validate coverage across accounts.

For each new control, document its policy type, attachment target, service
exceptions, operational owner, and rollback or recovery procedure.
