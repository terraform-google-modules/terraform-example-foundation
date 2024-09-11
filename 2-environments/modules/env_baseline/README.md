<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| assured\_workload\_configuration | Assured Workload configuration. See https://cloud.google.com/assured-workloads ."<br>  enabled: If the assured workload should be created.<br>  location: The location where the workload will be created.<br>  display\_name: User-assigned resource display name.<br>  compliance\_regime: Supported Compliance Regimes. See https://cloud.google.com/assured-workloads/docs/reference/rest/Shared.Types/ComplianceRegime .<br>  resource\_type: The type of resource. One of CONSUMER\_FOLDER, KEYRING, or ENCRYPTION\_KEYS\_PROJECT. | <pre>object({<br>    enabled           = optional(bool, false)<br>    location          = optional(string, "us-central1")<br>    display_name      = optional(string, "FEDRAMP-MODERATE")<br>    compliance_regime = optional(string, "FEDRAMP_MODERATE")<br>    resource_type     = optional(string, "CONSUMER_FOLDER")<br>  })</pre> | `{}` | no |
| env | The environment to prepare (ex. development) | `string` | n/a | yes |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization (ex. d). | `string` | n/a | yes |
| project\_budget | Budget configuration for projects.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.<br>  alert\_spend\_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default). | <pre>object({<br>    base_network_budget_amount                  = optional(number, 1000)<br>    base_network_alert_spent_percents           = optional(list(number), [1.2])<br>    base_network_alert_pubsub_topic             = optional(string, null)<br>    base_network_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")<br>    restricted_network_budget_amount            = optional(number, 1000)<br>    restricted_network_alert_spent_percents     = optional(list(number), [1.2])<br>    restricted_network_alert_pubsub_topic       = optional(string, null)<br>    restricted_network_budget_alert_spend_basis = optional(string, "FORECASTED_SPEND")<br>    secret_budget_amount                        = optional(number, 1000)<br>    secret_alert_spent_percents                 = optional(list(number), [1.2])<br>    secret_alert_pubsub_topic                   = optional(string, null)<br>    secret_budget_alert_spend_basis             = optional(string, "FORECASTED_SPEND")<br>    kms_budget_amount                           = optional(number, 1000)<br>    kms_alert_spent_percents                    = optional(list(number), [1.2])<br>    kms_alert_pubsub_topic                      = optional(string, null)<br>    kms_budget_alert_spend_basis                = optional(string, "FORECASTED_SPEND")<br>  })</pre> | `{}` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| assured\_workload\_id | Assured Workload ID. |
| assured\_workload\_resources | Resources associated with the Assured Workload. |
| env\_folder | Environment folder created under parent. |
| env\_kms\_project\_id | Project for environment Cloud Key Management Service (KMS). |
| env\_secrets\_project\_id | Project for environment secrets. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
