# App Infra Core Module

This module provisions the runner-agnostic core baseline infrastructure required by Step 5 (`5-app-infra`) pipelines. It is consumed by all polymorphic runner modules (`app_infra_pipeline_cb`, `app_infra_pipeline_github`, `app_infra_pipeline_gitlab`, and `app_infra_pipeline_local`).

## Resources Created

- **Application Terraform State Buckets:** Dedicated GCS buckets (`${bucket_prefix}-${project_id}-${repo}-state`) for application workload state isolation.
- **Application Service Accounts:** Scoped least-privilege Terraform service accounts (`sa-tf-${repo}`) used to deploy application infrastructure.
- **Baseline IAM Bindings:** Grants `roles/storage.admin` on the state bucket, `roles/storage.objectViewer` on remote foundation state, and `roles/artifactregistry.writer` on runner registries.
- **Artifact Registry Repositories:** Segregated Docker repositories (`tf-runners`) used for Confidential Space and runner container images.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_infra\_repos | A list of repositories / workloads to create pipelines for. | `list(string)` | n/a | yes |
| bucket\_force\_destroy | When deleting a bucket, this boolean option will delete all contained objects. | `bool` | `true` | no |
| bucket\_prefix | Name prefix to use for state buckets. | `string` | `"bkt"` | no |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| kms\_key\_name | Optional KMS encryption key name for the state bucket. | `string` | `null` | no |
| project\_id | The project id where app infra core resources (SA, state buckets, artifact registry) will be created. | `string` | n/a | yes |
| remote\_tfstate\_bucket | Remote state bucket from 0-bootstrap / 4-projects to grant App SA read access. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| artifact\_registry\_name | Primary Artifact Registry repository name. |
| artifact\_registry\_repositories | Artifact Registry repositories mapped by repo. |
| default\_region | Default region where resources were created. |
| state\_bucket\_self\_links | GCS State Buckets self links mapped by repo. |
| state\_buckets | GCS State Buckets mapped by repo. |
| terraform\_service\_accounts | App Infra Pipeline Terraform Service Accounts emails mapped by repo. |
| terraform\_service\_accounts\_ids | App Infra Pipeline Terraform Service Accounts resource IDs mapped by repo. |
| terraform\_service\_accounts\_names | App Infra Pipeline Terraform Service Accounts names mapped by repo. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
