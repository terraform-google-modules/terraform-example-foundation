<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | `"us-central1"` | no |
| project\_budget | Budget configuration.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`. | <pre>object({<br>    budget_amount        = optional(number, 1000)<br>    alert_spent_percents = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    alert_pubsub_topic   = optional(string, null)<br>  })</pre> | `{}` | no |

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
