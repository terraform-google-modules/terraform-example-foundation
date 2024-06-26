<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_export\_dataset\_location | The location of the dataset for billing data export. | `string` | `null` | no |
| create\_access\_context\_manager\_access\_policy | Whether to create access context manager access policy. | `bool` | `true` | no |
| create\_unique\_tag\_key | Creates unique organization-wide tag keys by adding a random suffix to each key. | `bool` | `false` | no |
| data\_access\_logs\_enabled | Enable Data Access logs of types DATA\_READ, DATA\_WRITE for all GCP services. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN\_READ logs are enabled by default. | `bool` | `false` | no |
| domains\_to\_allow | The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the foundation. To add other domains you must also grant access to these domains to the Terraform Service Account used in the deploy. | `list(string)` | n/a | yes |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| enforce\_allowed\_worker\_pools | Whether to enforce the organization policy restriction on allowed worker pools for Cloud Build. | `bool` | `false` | no |
| essential\_contacts\_domains\_to\_allow | The list of domains that email addresses added to Essential Contacts can have. | `list(string)` | n/a | yes |
| essential\_contacts\_language | Essential Contacts preferred language for notifications, as a ISO 639-1 language code. See [Supported languages](https://cloud.google.com/resource-manager/docs/managing-notification-contacts#supported-languages) for a list of supported languages. | `string` | `"en"` | no |
| gcp\_groups | Groups to grant specific roles in the Organization.<br>  platform\_viewer: Google Workspace or Cloud Identity group that have the ability to view resource information across the Google Cloud organization.<br>  security\_reviewer: Google Workspace or Cloud Identity group that members are part of the security team responsible for reviewing cloud security<br>  network\_viewer: Google Workspace or Cloud Identity group that members are part of the networking team and review network configurations.<br>  scc\_admin: Google Workspace or Cloud Identity group that can administer Security Command Center.<br>  audit\_viewer: Google Workspace or Cloud Identity group that members are part of an audit team and view audit logs in the logging project.<br>  global\_secrets\_admin: Google Workspace or Cloud Identity group that members are responsible for putting secrets into Secrets Manage | <pre>object({<br>    audit_viewer         = optional(string, null)<br>    security_reviewer    = optional(string, null)<br>    network_viewer       = optional(string, null)<br>    scc_admin            = optional(string, null)<br>    global_secrets_admin = optional(string, null)<br>    kms_admin            = optional(string, null)<br>  })</pre> | `{}` | no |
| log\_export\_storage\_force\_destroy | (Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present. | `bool` | `false` | no |
| log\_export\_storage\_location | The location of the storage bucket used to export logs. | `string` | `null` | no |
| log\_export\_storage\_retention\_policy | Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. | <pre>object({<br>    is_locked             = bool<br>    retention_period_days = number<br>  })</pre> | `null` | no |
| log\_export\_storage\_versioning | (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted. | `bool` | `false` | no |
| project\_budget | Budget configuration for projects.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.<br>  alert\_spend\_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default). | <pre>object({<br>    dns_hub_budget_amount                       = optional(number, 1000)<br>    dns_hub_alert_spent_percents                = optional(list(number), [1.2])<br>    dns_hub_alert_pubsub_topic                  = optional(string, null)<br>    dns_hub_budget_alert_spend_basis            = optional(string, "FORECASTED_SPEND")<br>    base_net_hub_budget_amount                  = optional(number, 1000)<br>    base_net_hub_alert_spent_percents           = optional(list(number), [1.2])<br>    base_net_hub_alert_pubsub_topic             = optional(string, null)<br>    base_net_hub_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")<br>    base_network_budget_amount                  = optional(number, 1000)<br>    base_network_alert_spent_percents           = optional(list(number), [1.2])<br>    base_network_alert_pubsub_topic             = optional(string, null)<br>    base_network_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")<br>    restricted_net_hub_budget_amount            = optional(number, 1000)<br>    restricted_net_hub_alert_spent_percents     = optional(list(number), [1.2])<br>    restricted_net_hub_alert_pubsub_topic       = optional(string, null)<br>    restricted_net_hub_budget_alert_spend_basis = optional(string, "FORECASTED_SPEND")<br>    restricted_network_budget_amount            = optional(number, 1000)<br>    restricted_network_alert_spent_percents     = optional(list(number), [1.2])<br>    restricted_network_alert_pubsub_topic       = optional(string, null)<br>    restricted_network_budget_alert_spend_basis = optional(string, "FORECASTED_SPEND")<br>    interconnect_budget_amount                  = optional(number, 1000)<br>    interconnect_alert_spent_percents           = optional(list(number), [1.2])<br>    interconnect_alert_pubsub_topic             = optional(string, null)<br>    interconnect_budget_alert_spend_basis       = optional(string, "FORECASTED_SPEND")<br>    org_secrets_budget_amount                   = optional(number, 1000)<br>    org_secrets_alert_spent_percents            = optional(list(number), [1.2])<br>    org_secrets_alert_pubsub_topic              = optional(string, null)<br>    org_secrets_budget_alert_spend_basis        = optional(string, "FORECASTED_SPEND")<br>    org_billing_export_budget_amount            = optional(number, 1000)<br>    org_billing_export_alert_spent_percents     = optional(list(number), [1.2])<br>    org_billing_export_alert_pubsub_topic       = optional(string, null)<br>    org_billing_export_budget_alert_spend_basis = optional(string, "FORECASTED_SPEND")<br>    org_audit_logs_budget_amount                = optional(number, 1000)<br>    org_audit_logs_alert_spent_percents         = optional(list(number), [1.2])<br>    org_audit_logs_alert_pubsub_topic           = optional(string, null)<br>    org_audit_logs_budget_alert_spend_basis     = optional(string, "FORECASTED_SPEND")<br>    common_kms_budget_amount                    = optional(number, 1000)<br>    common_kms_alert_spent_percents             = optional(list(number), [1.2])<br>    common_kms_alert_pubsub_topic               = optional(string, null)<br>    common_kms_budget_alert_spend_basis         = optional(string, "FORECASTED_SPEND")<br>    scc_notifications_budget_amount             = optional(number, 1000)<br>    scc_notifications_alert_spent_percents      = optional(list(number), [1.2])<br>    scc_notifications_alert_pubsub_topic        = optional(string, null)<br>    scc_notifications_budget_alert_spend_basis  = optional(string, "FORECASTED_SPEND")<br>  })</pre> | `{}` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| scc\_notification\_filter | Filter used to create the Security Command Center Notification, you can see more details on how to create filters in https://cloud.google.com/security-command-center/docs/how-to-api-filter-notifications#create-filter | `string` | `"state = \"ACTIVE\""` | no |
| scc\_notification\_name | Name of the Security Command Center Notification. It must be unique in the organization. Run `gcloud scc notifications describe <scc_notification_name> --organization=org_id` to check if it already exists. | `string` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| base\_net\_hub\_project\_id | The Base Network hub project ID |
| billing\_sink\_names | The name of the sinks under billing account level. |
| cai\_monitoring\_artifact\_registry | CAI Monitoring Cloud Function Artifact Registry name. |
| cai\_monitoring\_asset\_feed | CAI Monitoring Cloud Function Organization Asset Feed name. |
| cai\_monitoring\_bucket | CAI Monitoring Cloud Function Source Bucket name. |
| cai\_monitoring\_topic | CAI Monitoring Cloud Function Pub/Sub Topic name. |
| common\_folder\_name | The common folder name |
| common\_kms\_project\_id | The org Cloud Key Management Service (KMS) project ID |
| dns\_hub\_project\_id | The DNS hub project ID |
| domains\_to\_allow | The list of domains to allow users from in IAM. |
| interconnect\_project\_id | The Dedicated Interconnect project ID |
| interconnect\_project\_number | The Dedicated Interconnect project number |
| logs\_export\_project\_linked\_dataset\_name | The resource name of the Log Bucket linked BigQuery dataset for the project destination. |
| logs\_export\_project\_logbucket\_name | The resource name for the Log Bucket created for the project destination. |
| logs\_export\_pubsub\_topic | The Pub/Sub topic for destination of log exports |
| logs\_export\_storage\_bucket\_name | The storage bucket for destination of log exports |
| network\_folder\_name | The network folder name. |
| org\_audit\_logs\_project\_id | The org audit logs project ID. |
| org\_billing\_export\_project\_id | The org billing export project ID |
| org\_id | The organization id |
| org\_secrets\_project\_id | The org secrets project ID |
| parent\_resource\_id | The parent resource id |
| parent\_resource\_type | The parent resource type |
| restricted\_net\_hub\_project\_id | The Restricted Network hub project ID |
| restricted\_net\_hub\_project\_number | The Restricted Network hub project number |
| scc\_notification\_name | Name of SCC Notification |
| scc\_notifications\_project\_id | The SCC notifications project ID |
| shared\_vpc\_projects | Base and restricted shared VPC Projects info grouped by environment (development, nonproduction, production). |
| tags | Tag Values to be applied on next steps. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
