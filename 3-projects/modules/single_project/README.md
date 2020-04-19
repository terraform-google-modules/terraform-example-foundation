<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
|  | The top level domain name for the organization | string | `""` | no |
| activate\_apis | The api to activate for the GCP project | list(string) | `<list>` | no |
| application\_name | The name of application where GCP resources relate | string | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| cost\_centre | The cost centre that links to the application | string | n/a | yes |
| enable\_networking | The flag to create subnets in shared VPC | bool | `"false"` | no |
| enable\_private\_dns | The flag to create private dns zone in shared VPC | bool | `"false"` | no |
| environment | The environment the single project belongs to | string | `"prod"` | no |
| folder\_id | The folder id where project will be created | string | n/a | yes |
| impersonate\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| project\_prefix | The name of the GCP project | string | n/a | yes |
| subnet\_ip\_cidr\_range | The CIDR Range of the subnet to get allocated to the project | string | `""` | no |
| subnet\_secondary\_ranges | The secondary CIDR Ranges of the subnet to get allocated to the project | object | `<list>` | no |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
