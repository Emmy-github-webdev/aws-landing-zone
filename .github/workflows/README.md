# GitHub Actions workflows

The workflows in this directory run Terraform for the landing zone. Most
environment workflows call the shared
[`terraform-reusable.yml`](./terraform-reusable.yml); the initial state-bucket
bootstrap workflow runs Terraform directly.

## Workflows

| Workflow | Working directory | State key | Dispatch actions |
| --- | --- | --- | --- |
| [`bootstrap.yml`](./bootstrap.yml) | `terraform/bootstrap` | Configured by the bootstrap Terraform backend | `plan`, `apply` |
| [`management-bootstrap.yml`](./management-bootstrap.yml) | `terraform/environments/management-bootstrap` | `landing-zone/management-bootstrap/terraform.tfstate` | `plan`, `apply`, `destroy` |
| [`organizations.yml`](./organizations.yml) | `terraform/environments/organizations` | `landing-zone/organizations/terraform.tfstate` | `plan`, `apply`, `destroy` |
| [`governance.yml`](./governance.yml) | `terraform/environments/governance` | `landing-zone/governance/terraform.tfstate` | `plan`, `apply`, `destroy` |
| [`security.yml`](./security.yml) | `terraform/environments/security` | `landing-zone/security/terraform.tfstate` | `plan`, `apply`, `destroy` |
| [`networking.yml`](./networking.yml) | `terraform/environments/networking` | `landing-zone/networking/terraform.tfstate` | `plan`, `apply`, `destroy` |

The five environment workflows listen for pull requests, pushes to `main`,
and manual dispatches. They pass their environment name, working directory,
state key, Terraform version (`1.10.5`), and AWS Region (`us-east-1`) to the
reusable workflow. Each uses a separate concurrency group and cancels an older
run in that group when a new one starts.

The standalone bootstrap workflow is manual-only. It supports `plan` and
`apply`; it does not offer a destroy action or use the shared deployment
workflow.

## Shared Terraform job

For workflows that call `terraform-reusable.yml`, the job:

1. Checks out the repository and installs the requested Terraform version.
2. Checks that `AWS_ROLE_ARN` is present and configures AWS credentials using
   GitHub's OIDC integration.
3. Runs `terraform fmt -check -recursive`, initializes the S3 backend, and
   runs `terraform validate`.
4. Selects the Terraform action, creates a saved plan when planning or
   applying, and uploads the plan artifact for one day.
5. Applies the saved plan when the selected action is `apply` and
   `apply_enabled` is true. For `destroy`, runs `terraform destroy` with
   `-auto-approve`.

With the default `action: auto`, a push to `main` selects `apply`; other
events, including pull requests, select `plan`. A manual dispatch defaults to
`plan`, and its selected `plan`, `apply`, or `destroy` action overrides `auto`.
An `apply` still runs a plan first and applies that generated plan in the same
job; the plan artifact is for review and retention, not a separate approval
step.

All current callers set `apply_enabled: true`. Therefore pushes to `main`
that reach a deployment workflow can apply changes, subject to the configured
GitHub Environment protections and AWS role permissions. The `destroy` action
is destructive and is auto-approved by Terraform; restrict who can dispatch
it and use environment approval rules appropriate to each environment.

## Repository configuration

Configure the following for the GitHub Actions Environment named by each
workflow (for example, `security` or `governance`):

- `AWS_ROLE_ARN` secret: the IAM role for GitHub Actions to assume through
  OIDC. Its trust policy should be limited to this repository and the intended
  branches/environments.
- `TF_STATE_BUCKET` variable: the S3 bucket used by the shared workflow for
  Terraform state.
- Environment reviewers or deployment restrictions, if required to gate
  applies and destroys.

The shared job grants `contents: read`, `id-token: write`, and
`pull-requests: write`. The AWS Region input is used for credential setup and
backend configuration. Terraform state uses S3 encryption and the S3 lockfile
mechanism.

## Important: path filters currently need correction

The five environment workflow files use path filters such as
`modules/security/**` and `environments/security/**`. In this repository,
those directories are under `terraform/`:
[`terraform/modules/`](../../terraform/modules/) and
[`terraform/environments/`](../../terraform/environments/). As written, edits
to Terraform module or environment files do not match those filters, so they
will not trigger the corresponding workflow by themselves. Changes to the
workflow YAML files themselves still match. Update the filters to include the
`terraform/` prefix before relying on automatic runs after Terraform code
changes.
