<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| audit\_data\_users | Google Workspace or Cloud Identity group that have access to audit logs. | `string` | n/a | yes |
| audit\_logs\_table\_delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| audit\_logs\_table\_expiration\_days | Period before tables expire for all audit logs in milliseconds. Default is 30 days. | `number` | `30` | no |
| base\_net\_hub\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the base net hub project. | `string` | `null` | no |
| base\_net\_hub\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the base net hub project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| base\_net\_hub\_project\_budget\_amount | The amount to use as the budget for the base net hub project. | `number` | `1000` | no |
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| billing\_data\_users | Google Workspace or Cloud Identity group that have access to billing data set. | `string` | n/a | yes |
| create\_access\_context\_manager\_access\_policy | Whether to create access context manager access policy | `bool` | `true` | no |
| data\_access\_logs\_enabled | Enable Data Access logs of types DATA\_READ, DATA\_WRITE and ADMIN\_READ for all GCP services. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access | `bool` | `true` | no |
| default\_region | Default region for BigQuery resources. | `string` | n/a | yes |
| dns\_hub\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the DNS hub project. | `string` | `null` | no |
| dns\_hub\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the DNS hub project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| dns\_hub\_project\_budget\_amount | The amount to use as the budget for the DNS hub project. | `number` | `1000` | no |
| domains\_to\_allow | The list of domains to allow users from in IAM. Used by Domain Restricted Sharing Organization Policy. Must include the domain of the organization you are deploying the foundation. To add other domains you must also grant access to these domains to the terraform service account used in the deploy. | `list(string)` | n/a | yes |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| enable\_os\_login\_policy | Enable OS Login Organization Policy. | `bool` | `false` | no |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| gcp\_audit\_viewer | Members are part of an audit team and view audit logs in the logging project. | `string` | `null` | no |
| gcp\_billing\_admin\_user | Identity that has billing administrator permissions | `string` | `null` | no |
| gcp\_billing\_creator\_user | Identity that can create billing accounts. | `string` | `null` | no |
| gcp\_global\_secrets\_admin | G Suite or Cloud Identity group that members are responsible for putting secrets into Secrets Manager. | `string` | `null` | no |
| gcp\_network\_viewer | G Suite or Cloud Identity group that members are part of the networking team and review network configurations | `string` | `null` | no |
| gcp\_org\_admin\_user | Identity that has organization administrator permissions. | `string` | `null` | no |
| gcp\_platform\_viewer | G Suite or Cloud Identity group that have the ability to view resource information across the Google Cloud organization. | `string` | `null` | no |
| gcp\_scc\_admin | G Suite or Cloud Identity group that can administer Security Command Center. | `string` | `null` | no |
| gcp\_security\_reviewer | G Suite or Cloud Identity group that members are part of the security team responsible for reviewing cloud security. | `string` | `null` | no |
| interconnect\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the Dedicated Interconnect project. | `string` | `null` | no |
| interconnect\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the Dedicated Interconnect project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| interconnect\_project\_budget\_amount | The amount to use as the budget for the Dedicated Interconnect project. | `number` | `1000` | no |
| log\_export\_storage\_force\_destroy | (Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present. | `bool` | `false` | no |
| log\_export\_storage\_location | The location of the storage bucket used to export logs. | `string` | `"US"` | no |
| log\_export\_storage\_retention\_policy | Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. | <pre>object({<br>    is_locked             = bool<br>    retention_period_days = number<br>  })</pre> | `null` | no |
| log\_export\_storage\_versioning | (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted. | `bool` | `false` | no |
| org\_audit\_logs\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the org audit logs project. | `string` | `null` | no |
| org\_audit\_logs\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the org audit logs project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| org\_audit\_logs\_project\_budget\_amount | The amount to use as the budget for the org audit logs project. | `number` | `1000` | no |
| org\_billing\_logs\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the org billing logs project. | `string` | `null` | no |
| org\_billing\_logs\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the org billing logs project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| org\_billing\_logs\_project\_budget\_amount | The amount to use as the budget for the org billing logs project. | `number` | `1000` | no |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| org\_secrets\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the org secrets project. | `string` | `null` | no |
| org\_secrets\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the org secrets project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| org\_secrets\_project\_budget\_amount | The amount to use as the budget for the org secrets project. | `number` | `1000` | no |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| project\_prefix | Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters. | `string` | `"prj"` | no |
| restricted\_net\_hub\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the restricted net hub project. | `string` | `null` | no |
| restricted\_net\_hub\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the restricted net hub project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| restricted\_net\_hub\_project\_budget\_amount | The amount to use as the budget for the restricted net hub project. | `number` | `1000` | no |
| scc\_notification\_filter | Filter used to create the Security Command Center Notification, you can see more details on how to create filters in https://cloud.google.com/security-command-center/docs/how-to-api-filter-notifications#create-filter | `string` | `"state = \"ACTIVE\""` | no |
| scc\_notification\_name | Name of the Security Command Center Notification. It must be unique in the organization. Run `gcloud scc notifications describe <scc_notification_name> --organization=org_id` to check if it already exists. | `string` | n/a | yes |
| scc\_notifications\_project\_alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the SCC notifications project. | `string` | `null` | no |
| scc\_notifications\_project\_alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded for the SCC notifications project. | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| scc\_notifications\_project\_budget\_amount | The amount to use as the budget for the SCC notifications project. | `number` | `1000` | no |
| skip\_gcloud\_download | Whether to skip downloading gcloud (assumes gcloud is already available outside the module. If set to true you, must ensure that Gcloud Alpha module is installed.) | `bool` | `true` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| base\_net\_hub\_project\_id | The Base Network hub project ID |
| common\_folder\_name | The common folder name |
| dns\_hub\_project\_id | The DNS hub project ID |
| domains\_to\_allow | The list of domains to allow users from in IAM. |
| interconnect\_project\_id | The Dedicated Interconnect project ID |
| logs\_export\_pubsub\_topic | The Pub/Sub topic for destination of log exports |
| logs\_export\_storage\_bucket\_name | The storage bucket for destination of log exports |
| org\_audit\_logs\_project\_id | The org audit logs project ID |
| org\_billing\_logs\_project\_id | The org billing logs project ID |
| org\_id | The organization id |
| org\_secrets\_project\_id | The org secrets project ID |
| parent\_resource\_id | The parent resource id |
| parent\_resource\_type | The parent resource type |
| restricted\_net\_hub\_project\_id | The Restricted Network hub project ID |
| scc\_notification\_name | Name of SCC Notification |
| scc\_notifications\_project\_id | The SCC notifications project ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
