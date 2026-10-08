# Business Unit Shared Infrastructure & App Infra Pipeline

This environment provisions the shared infrastructure and CI/CD pipelines for Business Unit 1 applications (`5-app-infra`).

## Architecture: Polymorphic Module Interface Pattern

To support multiple CI/CD runners (Cloud Build, GitHub Actions, GitLab CI, and Local Execution) with static compiler safety and minimal boilerplate, this root module adopts the **Polymorphic Module Interface Pattern**:

- `main_cb.tf`: Instantiates `module "app_infra_pipeline"` using `../../modules/app_infra_pipeline_cb` (Cloud Build + CSR).
- `main_github.tf.example`: Instantiates `module "app_infra_pipeline"` using `../../modules/app_infra_pipeline_github` (GitHub Actions + WIF).
- `main_gitlab.tf.example`: Instantiates `module "app_infra_pipeline"` using `../../modules/app_infra_pipeline_gitlab` (GitLab CI + WIF).
- `main_local.tf.example`: Instantiates `module "app_infra_pipeline"` using `../../modules/app_infra_pipeline_local` (Workstation impersonation).
- `versions_github.tf.example`: Isolates the `integrations/github` provider plugin.
- `versions_gitlab.tf.example`: Isolates the `gitlabhq/gitlab` provider plugin.

### Runner Switching

To switch runner type across stages, execute:

```bash
./scripts/choose_build_type.sh <cb|github|gitlab|local>
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| gh\_repos | Configuration for GitHub Repositories (owner). | <pre>object({<br>    owner = string<br>  })</pre> | `null` | no |
| gh\_token | Personal access token for GitHub. | `string` | `""` | no |
| gitlab\_token | Personal access token for GitLab. | `string` | `""` | no |
| gitlab\_url | GitLab URL. | `string` | `"https://gitlab.com"` | no |
| gl\_repos | Configuration for GitLab Repositories (owner). | <pre>object({<br>    owner = string<br>  })</pre> | `null` | no |
| iam\_propagation\_sleep\_duration | The duration to wait for IAM propagation across Cloud Build, Storage, and Artifact Registry (e.g., 60s, 2m). | `string` | `"60s"` | no |
| project\_budget | Budget configuration.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.<br>  alert\_spend\_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default). | <pre>object({<br>    budget_amount        = optional(number, 1000)<br>    alert_spent_percents = optional(list(number), [1.2])<br>    alert_pubsub_topic   = optional(string, null)<br>    alert_spend_basis    = optional(string, "FORECASTED_SPEND")<br>  })</pre> | `{}` | no |
| project\_deletion\_policy | The deletion policy for the project created. | `string` | `"PREVENT"` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| terraform\_docker\_tag\_version | TAG version of the terraform docker image. | `string` | `"v1"` | no |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |
| universe\_domain | The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Cloud Dedicated (GCD). | `string` | `"googleapis.com"` | no |

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
