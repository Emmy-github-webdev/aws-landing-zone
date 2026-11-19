# Networking module

This guide describes the networking Terraform that is currently in this
repository and the steps to deploy it through its environment wrapper. The
environment wrapper is [`terraform/environments/networking`](../../environments/networking);
do not run this multi-account module by itself because it depends on provider
aliases and account-specific configuration supplied by that wrapper.

## What this deployment creates

The module connects three AWS accounts in one primary region:

| Account | Main resources |
| --- | --- |
| Infrastructure | Infrastructure VPC, shared Transit Gateway, optional centralized egress VPC, DNS Resolver endpoints, DNS Firewall, and infrastructure logs |
| Production | Production VPC and its Transit Gateway attachment |
| NonProduction | NonProduction VPC and its Transit Gateway attachment |
| Logging | Central DNS Kinesis stream and DNS archive S3 bucket |

It creates private and isolated subnets in each workload VPC. If
`enable_centralized_egress` is true, it also creates firewall, Transit Gateway,
and public/NAT subnets in an Infrastructure-account egress VPC. There is no
separate shared-services VPC in this implementation.

CIDR values in the environment configuration are examples for this deployment,
not universal allocations. Confirm that every VPC and subnet range is
non-overlapping with other VPCs, connected networks, and on-premises networks
before applying.

## Traffic and log flows

### Inter-VPC traffic

The Transit Gateway is created in Infrastructure and shared with the AWS
Organization using Resource Access Manager (RAM). Each account attaches its VPC
to the gateway. Separate Transit Gateway route tables are used for
Infrastructure, Production, and NonProduction; routes and propagation allow
workload accounts to reach shared Infrastructure without explicitly
propagating Production routes into the NonProduction table or vice versa.
However, when centralized egress is enabled, each workload route table also
gets a default route to the egress attachment. Traffic to another workload VPC
could therefore follow that egress path. Separate route tables alone do not
guarantee workload isolation; constrain and verify cross-environment traffic
with the firewall policy and workload security controls.

### Centralized egress

When enabled, the Production and NonProduction private route tables send their
default route to the Transit Gateway. The egress VPC attachment uses appliance
mode, and traffic is steered through the Network Firewall endpoints before
reaching a per-AZ NAT Gateway and Internet Gateway. The reverse VPC routes send
workload-bound traffic back through the firewall endpoints to the Transit
Gateway.

The firewall rules use `firewall_home_net_cidrs` as `HOME_NET`, allow the
configured TCP and UDP ports (and TCP/53), and then drop other IP traffic.
Review these values carefully: they define outbound access. Egress and firewall
logging resources are conditional on `enable_centralized_egress`.

### DNS and DNS audit logs

Route 53 Resolver inbound and outbound endpoints are in the Infrastructure VPC.
The inbound endpoint accepts DNS over UDP/TCP 53 only from
`dns_allowed_query_cidrs` and `dns_onpremises_cidrs`. When
`dns_onpremises_resolver_ips` and `dns_private_domain` are set, the outbound
endpoint forwards that private domain to those DNS servers; the rule is shared
with the organization and associated with all three VPCs.

Each VPC has a local Route 53 Resolver query-log configuration and CloudWatch
Log Group. With `enable_dns_security` enabled, DNS query events are delivered
along these two independent paths:

1. CloudWatch Logs subscription filters in all three source accounts send
   events to the central CloudWatch Logs destination backed by a Kinesis Data
   Stream in Logging.
2. A per-account Amazon Data Firehose delivery stream subscribes directly to
   the same local log group and archives events in the Logging S3 bucket under
   `dns/<account>/year=.../month=.../day=.../`.

The Kinesis stream and the S3 archive are not connected to each other in this
Terraform. The Kinesis stream is configured with seven days of retention; this
module does not configure a consumer for it. Firehose performs CloudWatch Logs
decompression and message extraction before writing GZIP-compressed objects to
S3. Failed Firehose deliveries use the configured DNS error prefix.

The S3 archive enables versioning, AES-256 server-side encryption, public
access blocking, and S3 Object Lock in Compliance mode. The default retention
and lifecycle expiration use `dns_archive_retention_days` (365 days by default);
objects transition to Glacier Flexible Retrieval after
`dns_archive_transition_days` (90 days by default). Compliance retention is
intentionally difficult to shorten or bypass. Obtain approval for the retention
period before creating the bucket.

## How the hub-and-spoke and shared DNS work

The Infrastructure account owns the Transit Gateway and the central DNS
Resolver endpoints. Production and NonProduction are separate spoke VPCs:

```text
Production private subnets ───┐
                              ├── Transit Gateway ─── Infrastructure VPC
NonProduction private subnets┘                         ├── DNS Resolver endpoints
                                                       └── optional egress VPC
```

The Transit Gateway is shared with the AWS Organization using RAM, and each VPC
has its own attachment. Separate Transit Gateway route tables let Production
and NonProduction reach Infrastructure without explicitly propagating one
workload's route into the other's table. The workload VPC route tables send the
Infrastructure CIDR to the Transit Gateway, and Infrastructure has return
routes to both workload CIDRs. In this implementation those VPC routes are
associated with the private subnets; isolated subnet route tables do not
receive them. When centralized egress is enabled, the default routes to the
egress attachment may also provide a path between workload VPCs through the
firewall. Do not treat the separate route tables as a security boundary by
themselves; verify the effective routes and explicitly restrict cross-VPC
traffic.

The DNS rule is shared separately from the Transit Gateway. When the corporate
resolver IPs and domain are configured, Infrastructure creates a Route 53
Resolver forwarding rule, shares it through RAM, and associates it with all
three VPCs. A matching query from a workload follows this logical path:

```text
Workload or pod
  -> AmazonProvidedDNS in its VPC
  -> matching shared Resolver rule
  -> outbound Resolver endpoint in Infrastructure
  -> configured corporate DNS server on UDP/TCP 53
```

AmazonProvidedDNS is the VPC's built-in DNS resolver. Route 53 Resolver applies
the associated rule to matching names and forwards them through the outbound
endpoint. This is not simply a DNS packet routed from each workload to the
Infrastructure VPC over the Transit Gateway. The outbound endpoint does,
however, need a valid route to the corporate DNS server, permission through its
security group, and a working return path. The module does not create an
on-premises VPN/Direct Connect connection or an on-premises Transit Gateway
attachment, so provide that connectivity and its routes separately.

The inbound Resolver endpoint is for approved external DNS clients that need to
query names resolvable in AWS. Those clients also need an existing network path
to the endpoint IPs; the endpoint security group restricts DNS access to the
configured CIDRs. DNS Firewall is applied separately in each VPC and blocks
names on its configured domain list.

### Adding EKS and other workloads

For the current design, the normal starting point is to deploy Production
clusters and services into the existing Production VPC, and NonProduction
clusters and services into the existing NonProduction VPC. They already have
separate VPCs, accounts, and Transit Gateway routing domains. **You do not
normally need a new VPC, Resolver endpoint, or DNS service for every cluster or
application.**

- Use the existing private subnets for worker nodes and other workloads that
  should not receive public IP addresses. EKS control-plane networking uses
  ENIs in the subnets selected for the cluster; the control plane itself is
  managed by AWS, so public workload subnets are not required just to run EKS.
  Plan for adequate free subnet IP capacity across at least two Availability
  Zones, including addresses consumed by nodes, pod networking, and load
  balancers.
- Centralized egress can provide outbound access from those private subnets
  through the Transit Gateway, firewall, and NAT, if it is enabled and the
  firewall policy permits the required traffic. If workloads must have no
  internet egress, add the necessary VPC endpoints for the AWS services they
  use. The current module creates S3 and DynamoDB gateway endpoints only; it
  does not create the full set of endpoints that a private EKS environment may
  need.
- The current Production and NonProduction VPCs have no public workload
  subnets. Public subnets are needed only for resources intentionally exposed
  to the internet, such as an internet-facing load balancer. The public/NAT
  subnets in the optional egress VPC are in a different VPC and are not
  substitutes for public subnets in a workload VPC. Internal load balancers
  should use private subnets.
- Use the existing VPC DNS resolver and shared corporate forwarding rule for
  corporate names. Kubernetes service discovery inside a cluster is normally
  provided by CoreDNS; it does not require a separate Route 53 Resolver.
  Create or associate Route 53 private hosted zones only when applications need
  custom private DNS names, and public hosted zones only when publishing names
  to the internet. This module creates Resolver rules and DNS Firewall
  resources, not Route 53 hosted zones.
- Create EKS-specific IAM roles, cluster/node security groups, endpoint
  settings, and load-balancer configuration for each cluster. Treat those as
  workload/cluster configuration, not as a reason to duplicate the shared
  network layer.

A separate VPC can make sense when a cluster needs a distinct security or
compliance boundary, independent routing/lifecycle, or its own address space.
Before adding one, account for CIDR overlap, Transit Gateway attachment and
routes, DNS rule association, egress policy, and the extra operational cost.
It will not automatically inherit this module's Transit Gateway routes or
Resolver rule associations; configure each connection and association
explicitly.
The best default here is to reuse each environment's VPC and add dedicated
subnets only if isolation, IP capacity, or routing requirements justify them.
If workloads within an environment must be isolated from one another, add
explicit network controls (including Kubernetes network policies where
appropriate) or use a separate VPC when the boundary requires it; a separate
cluster alone does not provide VPC-level isolation.

## AWS services and why they are used

| Service | Purpose in this module |
| --- | --- |
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

## Files and responsibilities

| File | Responsibility |
| --- | --- |
| [`main.tf`](../../environments/networking/main.tf) and [`providers.tf`](../../environments/networking/providers.tf) | Environment wrapper: module call, provider aliases, and cross-account roles |
| [`variables.tf`](./variables.tf), [`locals.tf`](./locals.tf), [`data.tf`](./data.tf) | Network inputs, tags, derived subnet CIDRs, and account/AZ lookups |
| [`vpc.tf`](./vpc.tf), [`subnets.tf`](./subnets.tf), [`routing.tf`](./routing.tf) | Workload VPCs, subnet tiers, route tables, and VPC routes |
| [`transit-gateway.tf`](./transit-gateway.tf) | Transit Gateway, RAM share, VPC attachments, and route domains |
| [`egress-vpc.tf`](./egress-vpc.tf), [`egress-subnets.tf`](./egress-subnets.tf), [`egress-gateways.tf`](./egress-gateways.tf), [`egress-routing.tf`](./egress-routing.tf), [`network-firewall.tf`](./network-firewall.tf), [`firewall-policy.tf`](./firewall-policy.tf), [`firewall-logging.tf`](./firewall-logging.tf) | Optional centralized egress VPC, firewall policy, NAT, routes, and logs |
| [`endpoints.tf`](./endpoints.tf), [`security-group.tf`](./security-group.tf), [`security-groups.tf`](./security-groups.tf), [`vpc-flow-logs.tf`](./vpc-flow-logs.tf) | Gateway endpoints, security groups, and VPC traffic logging |
| [`dns-resolver.tf`](./dns-resolver.tf), [`dns-firewall.tf`](./dns-firewall.tf), [`dns-logging.tf`](./dns-logging.tf), [`dns-central-logging.tf`](./dns-central-logging.tf), [`dns-firehose.tf`](./dns-firehose.tf), [`dns-s3-archive.tf`](./dns-s3-archive.tf) | Resolver, DNS Firewall, query logging, cross-account delivery, and S3 archive |
| [`dns-firehose/`](./dns-firehose) | Reusable per-source Firehose stream, delivery role, and subscription filter |
| [`outputs.tf`](./outputs.tf), [`dns-outputs.tf`](./dns-outputs.tf), [`egress-output.tf`](./egress-output.tf) | IDs, ARNs, addresses, and names returned by the module |

## Prerequisites

Before deploying:

1. Have an AWS Organization with the Infrastructure, Production,
   NonProduction, and Logging accounts available.
2. Enable organization sharing for AWS RAM. The Infrastructure account must be
   allowed to share the Transit Gateway and Resolver rule with the organization.
3. Configure credentials that can access the Terraform state backend and assume
   the configured `OrganizationAccountAccessRole` in Infrastructure, Production,
   and NonProduction.
4. Configure the `aws.logging` provider's credentials for the Logging account.
   Unlike the other aliases, the current Logging provider has no `assume_role`
   block and uses the ambient AWS credentials.
5. Confirm that the configured Availability Zones are available in the
   participating accounts and that the Availability Zone IDs refer to the
   intended physical zones.
6. Confirm CIDR non-overlap, Transit Gateway/NAT/Network Firewall quotas,
   IAM permissions, and DNS reachability to the configured corporate resolver
   IPs.
7. Decide and approve DNS archive retention. The bucket name is constructed
   from the Logging account ID and primary region; S3 bucket names must be
   globally unique.
8. Configure real values in
   [`terraform/environments/networking/terraform.tfvars`](../../environments/networking/terraform.tfvars).
   In particular, review account IDs, region, VPC and egress CIDRs, AZ names and
   IDs, `firewall_home_net_cidrs`, allowed firewall ports, DNS source CIDRs,
   corporate resolver IPs/domain, and retention settings. Do not copy the
   illustrative CIDRs in old design notes without checking for conflicts.

For corporate DNS forwarding, set both the resolver IPs and the domain name.
Also ensure `dns_onpremises_cidrs` includes the permitted destination networks:
the Resolver security group uses this list for outbound DNS. Add only approved
sources to `dns_allowed_query_cidrs` and `dns_onpremises_cidrs`; empty lists
intentionally do not open those paths.

## Deploying

Run Terraform from the environment wrapper, not from this module directory.
The backend bucket must already exist and the current credentials must be
authorized to use it. The S3 backend is configured with lock-file support, so
use a Terraform release that supports the `use_lockfile` backend option.

From the repository root in PowerShell:

```powershell
terraform fmt -recursive terraform
terraform -chdir=terraform/environments/networking init
terraform -chdir=terraform/environments/networking validate
terraform -chdir=terraform/environments/networking plan -out=networking.tfplan
```

Review the plan before applying. Verify account IDs, all proposed CIDRs and
routes, DNS source/target ranges, firewall rules, S3 Object Lock retention, and
any resource replacement or deletion. With centralized egress enabled, the
plan changes default routes for both Production and NonProduction; schedule and
approve that routing change with the affected workload owners. Apply only an
approved saved plan:

```powershell
terraform -chdir=terraform/environments/networking apply networking.tfplan
```

After deployment, inspect the outputs:

```powershell
terraform -chdir=terraform/environments/networking output
```

Check the Transit Gateway attachments are available, confirm the expected
routes in the workload and egress route tables, and test DNS forwarding and
approved/blocked domain behavior from each VPC. Confirm that CloudWatch Logs
receives DNS and firewall events, that the central Kinesis stream receives
records, and that Firehose writes objects beneath each account's S3 prefix.
Also check the Firehose error prefix and delivery-stream metrics if objects do
not arrive.

## Implementation notes and limits

- The current workload subnets are private and isolated; there are no public
  workload subnets. Public/NAT subnets exist only in the optional egress VPC.
- S3 and DynamoDB gateway endpoints are implemented. The `enable_ssm_endpoints`
  input is declared in the module but there are no Systems Manager interface
  endpoint resources in the current implementation.
- The `enable_nat_gateway`, `single_nat_gateway`, and
  `egress_nat_gateway_per_az` inputs are declared but do not control the current
  NAT topology. When centralized egress is enabled, the implementation creates
  one NAT Gateway per configured egress Availability Zone.
- The DNS Firewall resources currently enforce the blocked-domain list. The
  declared allowed-domain and default-action inputs are not wired into firewall
  rules, so setting them does not currently change DNS policy.
- `enable_flow_logs` currently controls VPC Flow Logs for Infrastructure only.
- Central DNS logging/archive resources are conditional on
  `enable_dns_security`; centralized egress/firewall resources are conditional
  on `enable_centralized_egress`.
- The baseline in this guide documents the repository's Terraform, not every
  proposal in the pasted design notes. In particular, those notes mention
  separate shared-services/workload public subnets and other future phases that
  are not part of this module as written.
