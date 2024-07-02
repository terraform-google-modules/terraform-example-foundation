<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | The api to activate for the GCP project | `list(string)` | `[]` | no |
| app\_infra\_pipeline\_service\_accounts | The Service Accounts from App Infra Pipeline. | `map(string)` | `{}` | no |
| application\_name | The name of application where GCP resources relate | `string` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | `string` | n/a | yes |
| billing\_code | The code that's used to provide chargeback information | `string` | n/a | yes |
| business\_code | The code that describes which business unit owns the project | `string` | `"shared"` | no |
| enable\_cloudbuild\_deploy | Enable infra deployment using Cloud Build | `bool` | `false` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| folder\_id | The folder id where project will be created | `string` | n/a | yes |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| primary\_contact | The primary email contact for the project | `string` | n/a | yes |
| project\_budget | Budget configuration.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.<br>  alert\_spend\_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default). | <pre>object({<br>    budget_amount        = optional(number, 1000)<br>    alert_spent_percents = optional(list(number), [1.2])<br>    alert_pubsub_topic   = optional(string, null)<br>    alert_spend_basis    = optional(string, "FORECASTED_SPEND")<br>  })</pre> | `{}` | no |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. | `string` | n/a | yes |
| sa\_roles | A list of roles to give the Service Account from App Infra Pipeline. | `map(list(string))` | `{}` | no |
| secondary\_contact | The secondary email contact for the project | `string` | `""` | no |
| shared\_vpc\_host\_project\_id | Shared VPC host project ID | `string` | `""` | no |
| shared\_vpc\_subnets | List of the shared vpc subnets self links. | `list(string)` | `[]` | no |
| vpc | The type of VPC to attach the project to. Possible options are none, base, or restricted. | `string` | `"none"` | no |
| vpc\_service\_control\_attach\_dry\_run | Whether the project will be attached to a VPC Service Control Perimeter with an explicit dry run spec flag, which may use different values for the dry run perimeter compared to the ENFORCED perimeter. | `bool` | `false` | no |
| vpc\_service\_control\_attach\_enabled | Whether the project will be attached to a VPC Service Control Perimeter in ENFORCED MODE. | `bool` | `false` | no |
| vpc\_service\_control\_perimeter\_name | The name of a VPC Service Control Perimeter to add the created project to | `string` | `null` | no |
| vpc\_service\_control\_sleep\_duration | The duration to sleep in seconds before adding the project to a shared VPC after the project is added to the VPC Service Control Perimeter | `string` | `"5s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| enabled\_apis | VPC Service Control services. |
| project\_id | Project sample project id. |
| project\_number | Project sample project number. |
| sa | Project SA email |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
