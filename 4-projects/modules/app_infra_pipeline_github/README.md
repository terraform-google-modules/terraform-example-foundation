# App Infra Pipeline GitHub Module

This module implements the GitHub Actions CI/CD pipeline for Step 5 (`5-app-infra`). It provisions a dedicated CI/CD project, configures keyless Workload Identity Federation (WIF) for GitHub OIDC tokens, and automatically injects required secrets into the GitHub repository.

## Features

- **Keyless Authentication:** Establishes Workload Identity Federation with GitHub Actions using the `gh-oidc` module.
- **Core Baseline Integration:** Consumes `app_infra_core` for dedicated GCS state buckets and least-privilege Terraform service accounts.
- **Automatic Secrets Injection:** Injects `PROJECT_ID`, `WIF_PROVIDER_NAME`, `TF_BACKEND`, and `SERVICE_ACCOUNT_EMAIL` into GitHub Actions repository secrets.
- **Universal Output Contract:** Implements the 5 Lean Universal Outputs contract and returns dummy pass-throughs for legacy Cloud Build outputs.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. | `string` | `""` | no |
| app\_infra\_repos | A list of repositories / workloads to create pipelines for. | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| enforce\_vpcsc | Whether to enforce VPC Service Controls. | `bool` | `false` | no |
| folder\_id | The folder ID where the CI/CD project should be created. | `string` | n/a | yes |
| gh\_repos | Configuration for GitHub Repositories (owner). | <pre>object({<br>    owner = string<br>  })</pre> | `null` | no |
| gh\_token | Personal access token for GitHub. | `string` | `""` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_name | VPC Service Controls Perimeter Name. | `string` | `""` | no |
| project\_budget | Budget configuration. | `any` | `{}` | no |
| project\_deletion\_policy | The deletion policy for the project created. | `string` | `"PREVENT"` | no |
| project\_prefix | Prefix to use for project names. | `string` | n/a | yes |
| remote\_tfstate\_bucket | Bucket with remote state data to be used by the pipeline. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers\_id | CB apply triggers. |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts. |
| artifact\_registry\_repository\_id | Artifact Registry ID. |
| bootstrap\_cloudbuild\_project\_id | Cloudbuild project ID. |
| cicd\_project\_id | APP Infra CI/CD Project ID (CB, GitHub, or GitLab project; empty for local). |
| cloudbuild\_project\_id | APP Infra cloudbuild project id. |
| cloudbuild\_project\_number | APP Infra cloudbuild project number. |
| default\_region | Default region to create resources where applicable. |
| enable\_cloudbuild\_deploy | Enable infra deployment using Cloud Build. |
| image\_name | Image path used by confidential space instance. |
| log\_buckets | GCS Buckets to store Cloud Build logs. |
| plan\_triggers\_id | CB plan triggers. |
| repos | CSRs to store source code. |
| state\_buckets | GCS Buckets to store TF state. |
| terraform\_service\_accounts | APP Infra Pipeline Terraform Accounts. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
