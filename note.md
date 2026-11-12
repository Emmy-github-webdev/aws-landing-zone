1. Preventive governance policies (SCPs)
These policies prevent users and roles in member accounts from performing prohibited actions.

A. Organization protection
Policy

Purpose

Priority

Deny leaving organization

Prevent accounts from leaving the organization

Critical

Deny removing accounts

Prevent unauthorized account removal

Critical

Protect organization management

Restrict changes to organization configuration

High

Restrict OU modification

Prevent unauthorized OU movement or deletion

High

Restrict trusted access changes

Prevent disabling trusted service integrations

High

Restrict delegated administrator changes

Protect delegated administrator registrations

High

B. Region restrictions
You already have this.

Additional controls:

Policy

Purpose

Deny unapproved Regions

Restrict resource deployment to approved Regions

Protect global services

Allow necessary global-service operations

Restrict Region opt-in changes

Prevent unauthorized enabling of Regions

For your architecture, you could initially approve:

us-east-1

us-west-2

Be careful with global AWS services such as IAM, Route 53, and CloudFront when implementing Region restrictions.

C. Identity and access management
Policy

Purpose

Priority

Deny IAM user creation

Enforce centralized identity management

High

Deny IAM access key creation

Reduce long-lived credentials

High

Deny root access key creation

Prevent root access keys

Critical

Protect IAM administrator roles

Prevent unauthorized modification

Critical

Restrict IAM policy changes

Prevent privilege escalation

Critical

Deny disabling MFA-related security controls

Protect authentication controls

High

Restrict IAM users

Encourage IAM Identity Center

High

Protect service-linked roles

Avoid disruption of AWS services

High

I particularly recommend reducing reliance on IAM users and long-lived access keys, using IAM Identity Center and short-lived role sessions instead.

D. Logging and monitoring protection
This is particularly important because you have separate Audit and Log Archive accounts.

Policy

Purpose

Priority

Deny CloudTrail deletion

Prevent audit trail deletion

Critical

Deny CloudTrail stop logging

Prevent disabling audit logging

Critical

Deny CloudTrail modification

Protect logging configuration

Critical

Deny AWS Config disabling

Prevent disabling configuration recording

Critical

Deny Config recorder deletion

Preserve compliance monitoring

Critical

Protect CloudWatch log groups

Prevent unauthorized log deletion

High

Protect central logging S3 buckets

Prevent deletion of audit logs

Critical

Restrict log bucket policies

Prevent unauthorized access

Critical

E. Data protection and encryption
Policy

Purpose

Priority

Require encrypted S3 uploads

Prevent unencrypted object uploads

Critical

Protect S3 public access settings

Prevent public exposure

Critical

Restrict S3 bucket deletion

Protect important data

High

Require encrypted EBS volumes

Protect storage data

High

Require encrypted RDS databases

Protect database storage

High

Restrict KMS key deletion

Protect encryption keys

Critical

Restrict KMS key disabling

Prevent accidental loss of access

Critical

Protect Secrets Manager secrets

Restrict unauthorized secret deletion

High

Restrict snapshot sharing

Prevent external data exposure

High

Note: SCPs can prevent certain actions, but they cannot universally enforce every encryption setting. Combine them with AWS Config and supported service-specific controls.

F. Networking protection
Policy

Purpose

Priority

Restrict VPC deletion

Prevent accidental network destruction

High

Restrict Internet Gateway creation

Control internet exposure

High

Restrict VPC peering

Control network connectivity

High

Restrict Transit Gateway modification

Protect centralized connectivity

High

Restrict public IP assignment

Reduce unintended public exposure

High

Restrict security group modifications

Protect network access rules

High

Restrict default security group changes

Prevent insecure default configurations

High

Restrict VPC Flow Logs deletion

Preserve network visibility

High

G. Compute and workload protection
Policy

Purpose

Restrict unapproved EC2 instance types

Control compute usage

Require IMDSv2

Improve EC2 metadata security

Restrict public AMIs

Control image exposure

Restrict unapproved Lambda runtimes

Standardize workloads

Restrict public EKS endpoints

Protect Kubernetes control planes

Restrict unencrypted EBS volumes

Protect storage

Restrict unauthorized snapshot sharing

Prevent data leakage

H. Cost governance
Policy

Purpose

Restrict expensive instance families

Control infrastructure expenditure

Restrict expensive Regions

Prevent unexpected regional expenditure

Restrict expensive AWS services

Control service usage

Restrict marketplace subscriptions

Prevent unauthorized purchases

Restrict GPU instance deployment

Control expensive compute resources

For cost governance, combine SCPs with AWS Budgets, Cost Anomaly Detection, and Cost Explorer.

2. Resource Control Policies (RCPs)
RCPs are different from SCPs.

SCPs restrict what identities in your organization can do.

RCPs restrict how identities, including external identities, can access resources in your organization.

I recommend considering these:

Policy

Purpose

Deny external access to S3

Restrict access to S3 resources from outside your organization

Enforce HTTPS access

Require secure transport to supported resources

Restrict external resource access

Protect sensitive resources from external identities

Enforce resource access conditions

Apply centralized resource access restrictions

Protect sensitive S3 resources

Control external access to important buckets

RCP support is service-specific, so check supported services before designing your policies. 

AWS Organizations
+1

3. Declarative policies
These are particularly useful because they enforce supported AWS service configurations centrally, rather than relying exclusively on individual API-deny statements in SCPs.

Consider:

Policy

Purpose

EBS encryption enforcement

Centrally enforce supported EBS encryption settings

VPC public access restrictions

Control public internet exposure

Root user access restrictions

Govern supported root-user access settings

Backup configuration restrictions

Enforce supported backup-related service configurations

Declarative policies are useful where AWS provides native support for the configuration you want to enforce. 

AWS Prescriptive Guidance
+1

4. Other AWS Organizations policies
AWS Organizations supports additional policy types beyond SCPs and RCPs.

Policy type

Purpose

Recommendation

Service Control Policies

Restrict permissions

Essential

Resource Control Policies

Restrict resource access

Recommended

Declarative policies

Enforce service configurations

Recommended

Backup policies

Standardize backup plans

Essential

Tag policies

Enforce consistent resource tagging

Essential

AI services opt-out policies

Manage AI service data collection preferences

As required

Chatbot policies

Control access through chat applications

Optional

AWS Organizations policy types are documented in the AWS Organizations policy reference .

5. Detective governance policies (AWS Config)
Not everything should be prevented through SCPs. Some controls are better implemented through AWS Config.

I recommend these controls:

AWS Config rule / control

What it detects

s3-bucket-public-read-prohibited

Public S3 read access

s3-bucket-public-write-prohibited

Public S3 write access

s3-bucket-server-side-encryption-enabled

Missing S3 encryption

encrypted-volumes

Unencrypted EBS volumes

rds-storage-encrypted

Unencrypted RDS storage

restricted-ssh

SSH open to the internet

restricted-common-ports

Unrestricted access to sensitive ports

cloud-trail-enabled

Missing CloudTrail

multi-region-cloud-trail-enabled

Missing multi-region CloudTrail

iam-user-mfa-enabled

IAM users without MFA

root-account-mfa-enabled

Root account without MFA

vpc-flow-logs-enabled

VPCs without Flow Logs

guardduty-enabled-centralized

GuardDuty coverage gaps

securityhub-enabled

Security Hub coverage gaps

These can be centrally monitored using AWS Config aggregators in your Audit/Security account.

AWS Control Tower also provides preventive, detective, and proactive controls. 

AWS Prescriptive Guidance
+1

6. How I would structure governance in your Landing Zone
Given your existing accounts:

Management

Audit

Log Archive

Networking

Security

I recommend the following OU and policy structure.

AWS Organization Root

Organization-wide mandatory guardrails

Security OU

Protected
Audit

Log Archive

Security tooling

Logging, IAM protection, security monitoring, encryption

Infrastructure OU

Networking

Shared services

Network protection, connectivity, centralized services

Workloads OU

Production

Development

Encryption, access restrictions, backups, approved Regions

Sandbox OU

- Experimental accounts

Strict cost controls, restricted services, data protection

The management account should be kept separate from normal workloads. Remember that SCPs do not restrict the management account. 

AWS Organizations
+1

7. My recommended implementation priority
For your Terraform governance module, I would implement these first:

Priority

Governance policy

Implementation

1

Prevent leaving organization

SCP

2

Restrict AWS Regions

SCP

3

Protect CloudTrail

SCP

4

Protect AWS Config

SCP

5

Prevent root access keys

SCP

6

Restrict IAM privilege escalation

SCP

7

Protect S3 public access

SCP + Config

8

Enforce encryption

SCP + Config

9

Protect KMS keys

SCP

10

Restrict external resource sharing

RCP + SCP

11

Enforce resource tagging

Tag policy

12

Standardize backups

Backup policy

13

Enforce network security

SCP + Config

14

Centralize security monitoring

Security Hub + GuardDuty

15

Cost governance

Budgets + SCP where appropriate