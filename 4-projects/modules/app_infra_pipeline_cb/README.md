# App Infra Pipeline Cloud Build Module

This module implements the Cloud Build CI/CD pipeline for Step 5 (`5-app-infra`). It provisions a dedicated CI/CD project, source code repositories (CSR), Cloud Build build triggers, and integrates with `app_infra_core` for state buckets and service accounts.

## Features

- **Dedicated CI/CD Project:** Scoped to the Business Unit `common` folder.
- **Core Baseline Integration:** Consumes `app_infra_core` for dedicated GCS state buckets and least-privilege Terraform service accounts.
- **Cloud Source Repositories:** Provisions application config repositories and policy repositories.
- **Automated Triggers:** Provisions Cloud Build plan and apply triggers connected to target branches (`development`, `nonproduction`, `production`).
- **Confidential Space Image Build:** Automates the container image build and publishing to Artifact Registry.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. | `string` | `""` | no |
| app\_infra\_repos | A list of Cloud Source Repos to be created to hold app infra Terraform configs. | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associate projects with. | `string` | n/a | yes |
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| cloud\_build\_private\_worker\_pool\_id | ID of the Cloud Build private worker pool. | `string` | n/a | yes |
| cloud\_builder\_artifact\_repo | Artifact Registry (AR) repository that stores TF Cloud Builder images. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| enforce\_vpcsc | Whether to enforce VPC Service Controls. | `bool` | `false` | no |
| folder\_id | The folder ID where the CI/CD project should be created. | `string` | n/a | yes |
| iam\_propagation\_sleep\_duration | The duration to wait for IAM propagation across Cloud Build, Storage, and Artifact Registry. | `string` | `"60s"` | no |
| org\_id | GCP Organization ID. | `string` | n/a | yes |
| perimeter\_name | VPC Service Controls Perimeter Name. | `string` | `""` | no |
| project\_budget | Budget configuration. | `any` | `{}` | no |
| project\_deletion\_policy | The deletion policy for the project created. | `string` | `"PREVENT"` | no |
| project\_prefix | Prefix to use for project names. | `string` | n/a | yes |
| projects\_terraform\_sa | Projects Step Terraform Service Account. | `string` | `""` | no |
| remote\_tfstate\_bucket | Bucket with remote state data to be used by the pipeline. | `string` | n/a | yes |
| terraform\_docker\_tag\_version | TAG version of the terraform docker image. | `string` | `"v1"` | no |

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
