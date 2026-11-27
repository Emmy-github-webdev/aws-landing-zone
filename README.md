# AWS Landing Zone with Hybrid Network Connectivity

## Overview
This is a hybrid network connectivity project built with Terraform for an AWS landing zone.

On AWS, I used a Transit Gateway as the central hub for the Infrastructure, Production, and NonProduction VPCs. Terraform provisions the Customer Gateway and a Site-to-Site VPN with two IPsec tunnels. For dynamic routing, strongSwan terminates the tunnels on Ubuntu, and FRRouting exchanges routes with AWS using BGP. This lets the on-premises and AWS networks learn the routes they need without maintaining every route manually.

I also integrated the VPN with the centralized Network Firewall. Transit Gateway route tables steer traffic through the inspection VPC, and the return path follows the same inspection route. Firewall rules and security groups allow the required ICMP traffic while leaving other traffic subject to the existing policy.

On the Ubuntu side, the tunnel interfaces, IPsec settings, BGP peers, and network forwarding were configured to match the AWS tunnel parameters. The setup includes two tunnels for resilience, and BGP uses separate autonomous system numbers for the on-premises router and AWS.

Finally, I verified that both ends exchanged routes and that a device on-premises could reach a private AWS host. This project demonstrates infrastructure as code, hybrid networking, IPsec, BGP, network segmentation, and centralized traffic inspection.

## Aim
The goal was to connect an on-premises Ubuntu network securely to multiple AWS environments, while keeping traffic routed and inspected rather than opening direct, uncontrolled paths.

## Prerequsite

Before starting this project, ensure you have the following:

- **AWS Account**: An active AWS account with sufficient IAM permissions to provision VPCs, Transit Gateways, Site-to-Site VPNs, Customer Gateways, and AWS Network Firewall resources.
- **GitHub Repository**: A GitHub account to clone the project repository and manage the Terraform configuration.
- **Terraform**: Terraform CLI installed on your local workstation.
- **AWS CLI**: AWS Command Line Interface installed and configured with credentials to access your AWS account.
- **Ubuntu Virtual Machine**: At least one Ubuntu VM running in a virtualization environment (e.g., VirtualBox, VMware, or Hyper-V) to simulate an on-premises corporate network and act as the VPN endpoint.
- **Networking Knowledge**: Basic understanding of TCP/IP, subnetting, routing, IPsec VPNs, and BGP.
- **Linux Administration**: Basic familiarity with Ubuntu, command-line operations, and Linux network configuration.

## Technologies used

| Technologies | Purpose in this module |
| --- | --- |
| AWS Control Tower | Sets up and governs a secure, compliant multi-account AWS environment using best-practice blueprints |
| AWS Organization | Enables central governance and consistent management of your AWS resources across multiple accounts and AWS services |
| Dashboard & Governance |  Centralized visibility into provisioned accounts, OUs, and control compliance status, with drift detection and repair capabilities |
| Account Factory |  A configurable template (built on AWS Service Catalog) that automates provisioning new AWS accounts with pre-approved network, security, and access baselines. |
| Controls (Guardrails) | Pre-packaged rules (preventive, detective, or proactive) categorized as mandatory, strongly recommended, or elective to enforce compliance, data residency, and security standards. |
| Landing Zone | A baseline multi-account structure with Organizational Units (OUs), shared accounts (such as log archive and audit accounts), centralized AWS CloudTrail and AWS Config logging, and baseline security roles |
| Amazon VPC, subnets, route tables and routes | Isolate account networks, separate private/isolated tiers, and direct traffic |
| AWS Transit Gateway | Hub for inter-VPC connectivity and separate routing domains |
| AWS Resource Access Manager (RAM) | Shares the Transit Gateway and corporate Resolver rule across the organization |
| AWS Network Firewall | Inspects and filters centralized outbound traffic |
| Internet Gateway, NAT Gateway and Elastic IP | Provide controlled outbound internet access from the egress VPC; the NAT gateways use stable public IPs |
| Amazon Route 53 Resolver | Provides inbound DNS resolution and outbound forwarding to corporate DNS |
| Route 53 Resolver DNS Firewall | Applies the configured blocked-domain list to queries in each VPC |
| Amazon CloudWatch Logs | Stores local DNS query logs and Network Firewall flow/alert logs |
| CloudWatch Logs destinations and subscription filters | Stream query logs across accounts to the Logging account |
| Amazon Kinesis Data Streams | Central, short-retention stream destination for cross-account DNS log subscriptions |
| Amazon Data Firehose | Decompresses/extracts DNS log events and delivers archive objects to S3 |
| Amazon S3 | Central DNS audit archive with encryption, versioning, lifecycle, and Object Lock |
| AWS Identity and Access Management (IAM) | Allows AWS services to assume delivery/logging roles with scoped permissions |
| VPC Flow Logs | Captures VPC network traffic metadata in CloudWatch Logs (currently configured for Infrastructure) |
| Amazon VPC gateway endpoints | Provide private route-table access to S3 and DynamoDB without routing those services through the internet |
| Security groups | Restrict Resolver endpoint DNS access to configured networks and DNS servers |
| AWS Site-to-Site VPN | Enable secure site connections without the complexity of traditional VPNs |
| Terraform | Infrastructure as Code |
| Ubuntu Linux | Servers as onpremise/coperate network |
| strongSwan | IPsec-based VPN solution |
| FRRouting (FRR) | Internet routing protocol suite for Linux and Unix platforms. It implements BGP, OSPF, RIP, IS-IS, PIM, LDP, BFD |

## Architecture

_Hybrid Network design_

![](./images/Hybrid%20networking%20(centralized%20Transit%20Gateway%20with%20independent%20VPCs)%20-%20aws%20landing%20zone.jpeg)

## GitHub Repository Structure
```
aws-landing-zone/
│
├── modules/
│   ├── organizations/
│   │   ├── main.tf
│   │   ├── data.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── governance/
│   │   ├── main.tf
│   │   ├── policies.tf
│   │   ├── locals.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── security/
│   │   ├── main.tf
│   │   ├── cloudtrail.tf
│   │   ├── config.tf
│   │   ├── guardduty.tf
│   │   ├── securityhub.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── networking/
│       ├── main.tf
│       ├── transit-gateway.tf
│       ├── vpc.tf
│       ├── subnets.tf
│       ├── routing.tf
│       ├── endpoints.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── environments/
│   ├── organizations/
│   ├── governance/
│   ├── security/
│   └── networking/
│
├── bootstrap/
│   └── terraform-state/
│
├── .github/
│   └── workflows/
│       ├── organizations.yml
│       ├── governance.yml
│       ├── security.yml
│       └── networking.yml
│
├── .gitignore
└── README.md

```
## Implementation Steps

Follow the steps below to create AWS landing zone with multi AWS accounts and hybrid network connectivity to onpremise or corperate network.

### Step 1

#### Create the AWS Organization blueprints using AWS Control Tower
- Sign in to the [AWS management console](https://us-west-2.signin.aws.amazon.com/signin?redirect_uri=https%3A%2F%2Fconsole.aws.amazon.com%2Fconsole%2Fhome%3Fca-oauth-flow-id%3D35a2%26hashArgs%3D%2523%26isauthcode%3Dtrue%26nc2%3Dh_si%26oauthStart%3D1795782732465%26src%3Dheader-signin%26state%3DhashArgsFromTB_eu-north-1_3dbeb442f0847b8e&client_id=arn%3Aaws%3Asignin%3A%3A%3Aconsole%2Fcanvas&forceMobileApp=0&oauth_region=eu-north-1&code_challenge=nZ5ZNz5slX03CF9ICF4SgWApWn_4A0gLt8VNLtTL_uo&code_challenge_method=SHA-256) with your administrator user credentials.
- Navigate to the AWS Control Tower console at https://console.aws.amazon.com/controltower.
- Verify that you are working in your desired home Region.
- Choose Enable AWS Control Tower.
- Follow the instructions in the console, accepting all the default values. Select existing accounts, or create new accounts, for your Aggregator account and CloudTrail administrator account.
- Review your choices. Choose Enable AWS Control Tower.
- AWS Control Tower takes about 30 minutes to set up all of the resources in your landing zone.







































































=================================================================================================================================
=================================================================================================================================
=================================================================================================================================
This repository provides a Terraform-managed foundation for a multi-account AWS
landing zone. AWS Control Tower establishes the organization foundation;
separate Terraform environments manage organizational structure, governance,
central security services, and shared networking.

> **Deployment status:** Treat this repository as an implementation to review
> and adapt, not as a turnkey production deployment. Confirm all account IDs,
> regions, permissions, policy effects, network paths, retention settings, and
> workflow protections in your own AWS organization before applying changes.

## Compliance and assurance scope

This repository is framework-neutral. It does not claim certification,
attestation, or compliance with SOC 2, ISO/IEC 27001, NIST, PCI DSS, or any
other regulatory or industry framework. Deploying these resources alone does
not demonstrate compliance. The organization remains responsible for defining
applicable requirements, assessing control design and operation, and
maintaining evidence for its auditors and customers.

Use the guide as an infrastructure control baseline, then map each applicable
requirement to an accountable control owner, the actual implementation, and
evidence from your AWS accounts and change-management systems. Validate
framework-specific requirements with your compliance and legal teams. AWS
Control Tower and AWS security services provide capabilities; they do not
transfer the customer's responsibilities under the AWS Shared Responsibility
Model.

## Control ownership and evidence

Assign named owners and retain evidence in an approved, access-controlled
system. The examples below are evidence candidates, not evidence generated or
retained automatically by this repository.

| Control objective | Accountable owner | Evidence to retain |
| --- | --- | --- |
| Identity lifecycle, least privilege, and privileged access | Identity and cloud platform teams | Role and trust-policy reviews, access approvals, MFA and break-glass tests, access review records, and IAM Access Analyzer findings with disposition |
| Change authorization and separation of duties | Change owner and independent approver | Change record, reviewed pull request, exact plan and approval, workflow run, deployment result, and post-deployment verification |
| Organization guardrails and exceptions | Cloud governance team | Effective policy attachments, test results, approved exceptions with owner and expiry, and periodic policy review |
| Audit logging and security monitoring | Security operations team | CloudTrail delivery and integrity checks, security-service coverage, alert triage records, Config recorder coverage, and escalation evidence |
| Data protection and retention | Data owner and platform team | Data classification, bucket policies, encryption and retention settings, access reviews, recovery tests, and approved retention exceptions |
| Network security and segmentation | Network security team | Approved CIDR inventory, route and firewall reviews, connectivity tests, DNS policy tests, and centralized log delivery checks |
| Resilience and incident response | Service owner and security operations | Recovery procedures, backup/restore test results, incident runbooks, escalation contacts, and exercise outcomes |

For each retained evidence item, record its source, collection date, account and
Region, control owner, review status, and retention period. Keep evidence
tamper-resistant where required by policy. Do not place credentials, customer
data, raw security logs, or unreviewed Terraform plans in the repository.
Treat state files and saved plans as sensitive because they may contain
infrastructure details or secret values.

## Change control baseline

Apply the following controls to infrastructure changes, especially changes
that affect production accounts, organization policies, audit data, or network
routing:

1. Link the change to an approved request that identifies the purpose, scope,
   affected accounts and Regions, risk, owner, validation plan, and rollback or
   recovery approach.
2. Require peer review by the relevant platform, security, network, or
   governance owner. Review policy scope, identity permissions, data handling,
   resource replacement, and destructive effects—not only whether a plan
   completes successfully.
3. Verify that the plan targets the intended AWS organization, account,
   Region, and remote-state key. Approval must apply to the exact plan that is
   applied; regenerate and re-review it if the configuration or state changes.
4. Separate request, approval, and deployment responsibilities where required
   by organizational policy. Restrict production and destructive operations
   to explicitly authorized identities.
5. Capture the change record, review and approval, workflow run, plan reference,
   deployment result, and validation outcome in the designated evidence
   system. Apply the organization's retention and access controls to these
   records.
6. After deployment, verify the expected behavior in AWS, check for drift or
   failed service integrations, and record any exception with a named owner,
   compensating control, and review or expiry date.

The current workflows do not enforce this full baseline by themselves. In
particular, a retained plan artifact is not an approval gate for the apply in
that run, and pushes to `main` can select apply by default. Configure and test
the required GitHub Environment protections and workflow behavior before
using these workflows as a regulated change-control mechanism.

## Architecture at a glance

The current design separates responsibilities across these accounts and
deployment layers:

| Layer | Responsibility | Primary account(s) |
| --- | --- | --- |
| AWS foundation | AWS Organizations, Control Tower, identity, and account lifecycle | Management |
| Organizations | Organizational units, account placement, and Control Tower baselines | Management |
| Governance | Preventive organization guardrails and Service Control Policies | Management |
| Security | Central security services and audit logging | Security, Logging, and Management |
| Networking | Transit Gateway, account VPCs, shared DNS, and optional centralized egress | Infrastructure, Production, NonProduction, and Logging |
| State bootstrap | Remote Terraform state storage | Dedicated bootstrap context |

The workload network currently uses separate Infrastructure, Production, and
NonProduction accounts. The Security and Logging accounts are separate from the
Management account. Confirm that this layout matches your Control Tower
configuration; discover and adopt existing organization resources rather than
creating duplicates.

## Before you begin

Complete these preparation steps before deploying Terraform:

1. **Establish the AWS foundation.** Select the management account and intended
   Control Tower home Region. Create or verify the AWS Organization and an active
   Control Tower landing zone. The home Region is a foundational choice; changing
   it later is a migration or reconfiguration effort, not a routine setting
   change. See the [Control Tower quick start](https://docs.aws.amazon.com/controltower/latest/userguide/quick-start.html).
2. **Inventory accounts and organization resources.** Identify the Management,
   Security, Logging, Infrastructure, Production, and NonProduction accounts;
   record the organization ID, account IDs, existing OUs, enabled Regions, and
   existing Control Tower baselines. Determine which existing resources must be
   imported into Terraform state.
3. **Choose and validate Regions and network ranges.** Confirm the primary and
   secondary Regions used by the environment configuration and security
   services. Check VPC and subnet CIDRs against every connected VPC and
   on-premises network, and verify Availability Zone availability and service
   quotas.
4. **Prepare access and state management.** Use a controlled administrative
   session for initial setup. For GitHub Actions, configure AWS OIDC trust and
   least-privilege roles scoped to this repository and the intended branches or
   environments. Prepare a unique remote-state bucket and restrict access to
   authorized operators and deployment roles.
5. **Prepare account details and configuration.** Supply verified account IDs,
   organization identifiers, account email addresses where account creation is
   intended, role ARNs, Region selections, CIDRs, DNS settings, and retention
   values through the appropriate environment configuration. Never commit
   credentials or secret values.
6. **Set deployment protections.** Configure GitHub Environments, reviewers,
   branch restrictions, and role permissions before enabling changes to reach
   production accounts.

## Step-by-step deployment

Deploy one layer at a time. At each stage, review the proposed changes, verify
the target account and Region, and resolve unexpected replacements or deletions
before proceeding.

### 1. Create the Control Tower foundation

Use the AWS console to establish the organization and Control Tower landing
zone. Configure the required foundational accounts and baseline controls.
Review existing Security and Sandbox OUs and other organization resources
before deciding whether Terraform should manage them.

**Exit check:** Control Tower reports a healthy landing zone, the management
account and home Region are confirmed, and the intended member accounts are
available or their creation plan is approved.

### 2. Bootstrap remote Terraform state

Run the dedicated bootstrap deployment using an authorized AWS session. Create
the remote-state bucket before initializing the other Terraform environments.
Verify its name, Region, versioning, encryption, public-access protections,
access policy, and recovery process. Keep state files and saved plans out of
source control.

**Exit check:** The bucket is ready, access is limited to the required
operators and roles, and the backend settings for each environment point to
the correct bucket and unique state key.

### 3. Establish organization structure

Deploy the Organizations environment. Review the planned OU structure, account
placement, account imports or creation, and Control Tower baseline assignments.
Confirm that account and organization identifiers match the live organization;
do not apply a plan that proposes replacing or recreating existing accounts or
OUs unexpectedly.

**Exit check:** The intended OUs and account placements are present, existing
accounts are represented safely in Terraform state, and Control Tower
integrations remain healthy.

### 4. Prepare management-account security integrations

Deploy the management-bootstrap environment after the Security account and
organization structure are available. This stage prepares GuardDuty trusted
access and registers the Security account as the delegated administrator in
the configured Regions.

**Exit check:** Verify the delegated administrator registrations and
organization integration in AWS before deploying member security resources.

### 5. Apply organization governance

Deploy the Governance environment only after checking every policy attachment
target and evaluating its effects on account recovery, Control Tower
operations, security services, and deployment roles. Service Control Policies
set permission boundaries; they do not grant permissions. Begin with a
controlled rollout and confirm that emergency and administrative access paths
remain available.

**Exit check:** Confirm the effective policies on the intended OUs and test
representative allowed and denied actions in a non-production account.

### 6. Deploy centralized security services

Deploy the Security environment after verifying the Security, Management, and
Logging account identities, cross-account roles, delegated administrators,
trusted service access, and Region configuration. Review the plan for
organization-wide changes and confirm that audit logs reach the intended
Logging account.

The AWS Config aggregator is not a substitute for Config recorders, delivery
channels, or rules in member accounts. Verify account enrollment and regional
coverage for each service independently.

**Exit check:** Confirm service administration, account and Region coverage,
CloudTrail delivery, security findings, and required retention and deletion
protections.

### 7. Deploy shared networking

Deploy the Networking environment after the participating accounts, cross-
account roles, and AWS RAM organization sharing are ready. Validate CIDR
non-overlap, Transit Gateway attachments and routes, DNS access ranges,
corporate resolver reachability, firewall policy, egress routes, and DNS log
retention. Stage routing changes: verify the inspection and return paths, test
a non-production workload, and coordinate production route changes with
workload owners.

**Exit check:** Verify attachment state and effective routes in each account;
test approved DNS forwarding and filtering; and confirm that expected DNS and
firewall logs reach their central destinations.

### 8. Operate deployments through GitHub Actions

Use the environment-specific workflows for ongoing changes after reviewing
their configuration and access controls. Configure OIDC role trust, GitHub
Environment approvals, and branch protections for each deployment target.
Inspect every plan and ensure approval applies to the exact change being
deployed. Restrict destructive actions to authorized operators and require an
independent review of their impact.

Read [GitHub Actions workflow documentation](./.github/workflows/README.md)
before relying on automated runs. The current workflow path filters need
correction to include the repository's `terraform/` directory, and pushes to
`main` can select apply by default. A plan artifact is retained for review but
is not, by itself, an approval gate for the apply in that run.

### 9. Verify and hand over

Record the deployed account, Region, state key, workflow run, and approval for
each environment. Validate service health, organization policy inheritance,
network connectivity, logging delivery, alert ownership, and recovery
procedures. Document exceptions and assign an operational owner for each
control before onboarding production workloads.

## Production-readiness checks

Resolve these repository-specific items before treating the deployment as
production-ready:

- The state bootstrap currently uses SSE-S3 encryption and has a
  testing-oriented `prevent_destroy` setting. Decide whether your policy
  requires customer-managed key controls, enable appropriate deletion
  protection, and test state recovery before production use.
- The Governance module's current Region restriction policy is hard-coded;
  changing the `approved_regions` input alone does not update that policy.
  Review the policy document and its global-service exceptions before
  attachment.
- The Security module's `cloudtrail_retention_days` input currently does not
  configure S3 lifecycle expiration. Define, implement, and verify retention
  and noncurrent-version handling against your records policy before relying on
  it for audit retention.
- The GitHub Actions path filters currently omit the `terraform/` prefix for
  environment files. Changes to Terraform files may therefore not trigger the
  expected workflow automatically. The deployment behavior and protections
  are described in the [workflow guide](./.github/workflows/README.md).
- Security and networking features have implementation-specific prerequisites
  and limitations. Review the [Governance guide](./terraform/modules/governance/README.md),
  [Security guide](./terraform/modules/security/README.md), and
  [Networking guide](./terraform/modules/networking/README.md) before enabling
  their respective layers.

## Repository guides

- [GitHub Actions workflows](./.github/workflows/README.md): triggers, actions,
  state keys, OIDC configuration, and deployment behavior.
- [Governance module](./terraform/modules/governance/README.md): active
  Service Control Policies, deployment prerequisites, and governance roadmap.
- [Security module](./terraform/modules/security/README.md): deployed services,
  account and Region behavior, and operational considerations.
- [Networking module](./terraform/modules/networking/README.md): account
  topology, traffic flows, prerequisites, validation, and current limitations.