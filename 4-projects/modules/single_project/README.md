<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| activate\_apis | The api to activate for the GCP project | `list(string)` | `[]` | no |
| alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| application\_name | The name of application where GCP resources relate | `string` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | `string` | n/a | yes |
| billing\_code | The code that's used to provide chargeback information | `string` | n/a | yes |
| budget\_amount | The amount to use as the budget | `number` | `1000` | no |
| business\_code | The code that describes which business unit owns the project | `string` | `"abcd"` | no |
| cloudbuild\_sa | The Cloud Build SA used for deploying infrastructure in this project. It will impersonate the new default SA created | `string` | `""` | no |
| enable\_cloudbuild\_deploy | Enable infra deployment using Cloud Build | `bool` | `false` | no |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| folder\_id | The folder id where project will be created | `string` | n/a | yes |
| impersonate\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| primary\_contact | The primary email contact for the project | `string` | n/a | yes |
| project\_prefix | Name prefix to use for projects created. | `string` | `"prj"` | no |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. | `string` | n/a | yes |
| sa\_roles | A list of roles to give the Service Account for the project (defaults to none) | `list(string)` | `[]` | no |
| secondary\_contact | The secondary email contact for the project | `string` | `""` | no |
| vpc\_service\_control\_attach\_enabled | Whether the project will be attached to a VPC Service Control Perimeter | `bool` | `false` | no |
| vpc\_service\_control\_perimeter\_name | The name of a VPC Service Control Perimeter to add the created project to | `string` | `null` | no |
| vpc\_type | The type of VPC to attach the project to. Possible options are base or restricted. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| enabled\_apis | VPC Service Control services. |
| project\_id | Project sample project id. |
| project\_number | Project sample project number. |
| sa | Project SA email |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
