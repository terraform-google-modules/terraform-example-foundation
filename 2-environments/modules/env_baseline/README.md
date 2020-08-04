<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associate this project with | string | n/a | yes |
| env | The environment to prepare (ex. development) | string | n/a | yes |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization (ex. d). | string | n/a | yes |
| monitoring\_workspace\_users | Gsuite or Cloud Identity group that have access to Monitoring Workspaces. | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| parent\_id | The parent folder or org for environments | string | n/a | yes |
| skip\_gcloud\_download | Whether to skip downloading gcloud (assumes gcloud is already available outside the module) | bool | `"true"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| base\_shared\_vpc\_project\_id | Project for monitoring infra. |
| env\_folder | Environment folder created under parent. |
| env\_secrets\_project\_id | Project for monitoring infra. |
| monitoring\_project\_id | Project for monitoring infra. |
| restricted\_shared\_vpc\_project\_id | Project for monitoring infra. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
