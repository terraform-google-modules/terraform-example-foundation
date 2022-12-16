<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| audit\_data\_users | Google Workspace or Cloud Identity group that have access to audit logs. | `string` | n/a | yes |
| audit\_logs\_table\_delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| audit\_logs\_table\_expiration\_days | Period before tables expire for all audit logs in milliseconds. Default is 30 days. | `number` | `30` | no |
| billing\_data\_users | Google Workspace or Cloud Identity group that have access to billing data set. | `string` | n/a | yes |
| billing\_export\_dataset\_location | The location of the dataset for billing data export. | `string` | `"US"` | no |
| create\_access\_context\_manager\_access\_policy | Whether to create access context manager access policy. | `bool` | `true` | no |
| create\_unique\_tag\_key | Creates unique organization-wide tag keys by adding a random suffix to each key. | `bool` | `false` | no |
| data\_access\_logs\_enabled | Enable Data Access logs of types DATA\_READ, DATA\_WRITE for all GCP services. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN\_READ logs are enabled by default. | `bool` | `false` | no |
| domains\_to\_allow | The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the foundation. To add other domains you must also grant access to these domains to the Terraform Service Account used in the deploy. | `list(string)` | n/a | yes |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| enforce\_allowed\_worker\_pools | Whether to enforce the organization policy restriction on allowed worker pools for Cloud Build. | `bool` | `false` | no |
| essential\_contacts\_domains\_to\_allow | The list of domains that email addresses added to Essential Contacts can have. | `list(string)` | n/a | yes |
| essential\_contacts\_language | Essential Contacts preferred language for notifications, as a ISO 639-1 language code. See [Supported languages](https://cloud.google.com/resource-manager/docs/managing-notification-contacts#supported-languages) for a list of supported languages. | `string` | `"en"` | no |
| gcp\_groups | Groups to grant specific roles in the Organization.<br>  platform\_viewer: Google Workspace or Cloud Identity group that have the ability to view resource information across the Google Cloud organization.<br>  security\_reviewer: Google Workspace or Cloud Identity group that members are part of the security team responsible for reviewing cloud security<br>  network\_viewer: Google Workspace or Cloud Identity group that members are part of the networking team and review network configurations.<br>  scc\_admin: Google Workspace or Cloud Identity group that can administer Security Command Center.<br>  audit\_viewer: Google Workspace or Cloud Identity group that members are part of an audit team and view audit logs in the logging project.<br>  global\_secrets\_admin: Google Workspace or Cloud Identity group that members are responsible for putting secrets into Secrets Manage | <pre>object({<br>    platform_viewer      = optional(string, null)<br>    security_reviewer    = optional(string, null)<br>    network_viewer       = optional(string, null)<br>    scc_admin            = optional(string, null)<br>    audit_viewer         = optional(string, null)<br>    global_secrets_admin = optional(string, null)<br>  })</pre> | `{}` | no |
| gcp\_user | Users to grant specific roles in the Organization.<br>  org\_admin: Identity that has organization administrator permissions.<br>  billing\_creator: Identity that can create billing accounts.<br>  billing\_admin: Identity that has billing administrator permissions. | <pre>object({<br>    org_admin       = optional(string, null)<br>    billing_creator = optional(string, null)<br>    billing_admin   = optional(string, null)<br>  })</pre> | `{}` | no |
| log\_export\_storage\_force\_destroy | (Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present. | `bool` | `false` | no |
| log\_export\_storage\_location | The location of the storage bucket used to export logs. | `string` | `"US"` | no |
| log\_export\_storage\_retention\_policy | Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. | <pre>object({<br>    is_locked             = bool<br>    retention_period_days = number<br>  })</pre> | `null` | no |
| log\_export\_storage\_versioning | (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted. | `bool` | `false` | no |
| project\_budget | Budget configuration for projects.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`. | <pre>object({<br>    dns_hub_budget_amount                   = optional(number, 1000)<br>    dns_hub_alert_spent_percents            = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    dns_hub_alert_pubsub_topic              = optional(string, null)<br>    base_net_hub_budget_amount              = optional(number, 1000)<br>    base_net_hub_alert_spent_percents       = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    base_net_hub_alert_pubsub_topic         = optional(string, null)<br>    restricted_net_hub_budget_amount        = optional(number, 1000)<br>    restricted_net_hub_alert_spent_percents = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    restricted_net_hub_alert_pubsub_topic   = optional(string, null)<br>    interconnect_budget_amount              = optional(number, 1000)<br>    interconnect_alert_spent_percents       = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    interconnect_alert_pubsub_topic         = optional(string, null)<br>    org_secrets_budget_amount               = optional(number, 1000)<br>    org_secrets_alert_spent_percents        = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    org_secrets_alert_pubsub_topic          = optional(string, null)<br>    org_billing_logs_budget_amount          = optional(number, 1000)<br>    org_billing_logs_alert_spent_percents   = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    org_billing_logs_alert_pubsub_topic     = optional(string, null)<br>    org_audit_logs_budget_amount            = optional(number, 1000)<br>    org_audit_logs_alert_spent_percents     = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    org_audit_logs_alert_pubsub_topic       = optional(string, null)<br>    scc_notifications_budget_amount         = optional(number, 1000)<br>    scc_notifications_alert_spent_percents  = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    scc_notifications_alert_pubsub_topic    = optional(string, null)<br>  })</pre> | `{}` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| scc\_notification\_filter | Filter used to create the Security Command Center Notification, you can see more details on how to create filters in https://cloud.google.com/security-command-center/docs/how-to-api-filter-notifications#create-filter | `string` | `"state = \"ACTIVE\""` | no |
| scc\_notification\_name | Name of the Security Command Center Notification. It must be unique in the organization. Run `gcloud scc notifications describe <scc_notification_name> --organization=org_id` to check if it already exists. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| base\_net\_hub\_project\_id | The Base Network hub project ID |
| common\_folder\_name | The common folder name |
| dns\_hub\_project\_id | The DNS hub project ID |
| domains\_to\_allow | The list of domains to allow users from in IAM. |
| interconnect\_project\_id | The Dedicated Interconnect project ID |
| interconnect\_project\_number | The Dedicated Interconnect project number |
| logs\_export\_bigquery\_dataset\_name | The log bucket for destination of log exports. See https://cloud.google.com/logging/docs/routing/overview#buckets |
| logs\_export\_logbucket\_name | The log bucket for destination of log exports. See https://cloud.google.com/logging/docs/routing/overview#buckets |
| logs\_export\_pubsub\_topic | The Pub/Sub topic for destination of log exports |
| logs\_export\_storage\_bucket\_name | The storage bucket for destination of log exports |
| org\_audit\_logs\_project\_id | The org audit logs project ID |
| org\_billing\_logs\_project\_id | The org billing logs project ID |
| org\_id | The organization id |
| org\_secrets\_project\_id | The org secrets project ID |
| parent\_resource\_id | The parent resource id |
| parent\_resource\_type | The parent resource type |
| restricted\_net\_hub\_project\_id | The Restricted Network hub project ID |
| restricted\_net\_hub\_project\_number | The Restricted Network hub project number |
| scc\_notification\_name | Name of SCC Notification |
| scc\_notifications\_project\_id | The SCC notifications project ID |
| tags | Tag Values to be applied on next steps |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
