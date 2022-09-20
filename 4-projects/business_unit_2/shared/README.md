<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| backend\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |
| budget\_amount | The amount to use as the budget | `number` | `1000` | no |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| cloudbuild\_project\_id | n/a |
| cloudbuild\_sa | Cloud Build service account |
| default\_region | Default region to create resources where applicable. |
| plan\_triggers | CB plan triggers |
| repos | CSRs to store source code |
| state\_buckets | GCS Buckets to store TF state |
| tf\_runner\_artifact\_repo | GAR Repo created to store runner images |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
