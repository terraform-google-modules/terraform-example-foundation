<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| base\_network\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the base networks project | `string` | `null` | no |
| base\_network\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the base networks project | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| base\_network\_project\_budget\_amount | The amount to use as the budget for the base networks project | `number` | `1000` | no |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| env | The environment to prepare (ex. development) | `string` | n/a | yes |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization (ex. d). | `string` | n/a | yes |
| folder\_prefix | Name prefix to use for folders created. | `string` | `"fldr"` | no |
| monitoring\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the monitoring project. | `string` | `null` | no |
| monitoring\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the monitoring project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| monitoring\_project\_budget\_amount | The amount to use as the budget for the monitoring project. | `number` | `1000` | no |
| monitoring\_workspace\_users | Google Workspace or Cloud Identity group that have access to Monitoring Workspaces. | `string` | n/a | yes |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| parent\_id | The parent folder or org for environments | `string` | n/a | yes |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| restricted\_network\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the restricted networks project | `string` | `null` | no |
| restricted\_network\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the restricted networks project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| restricted\_network\_project\_budget\_amount | The amount to use as the budget for the restricted networks project. | `number` | `1000` | no |
| secret\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the secrets project. | `string` | `null` | no |
| secret\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the secrets project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| secret\_project\_budget\_amount | The amount to use as the budget for the secrets project. | `number` | `1000` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| base\_shared\_vpc\_project\_id | Project for base shared VPC network. |
| env\_folder | Environment folder created under parent. |
| env\_secrets\_project\_id | Project for environment secrets. |
| monitoring\_project\_id | Project for monitoring infra. |
| restricted\_shared\_vpc\_project\_id | Project for restricted shared VPC network. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
