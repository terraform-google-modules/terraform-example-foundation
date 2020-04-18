<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The api to activate for the GCP project | list(string) | `<list>` | no |
| application\_name | The name of application where GCP resources relate | string | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| cost\_centre | The cost centre that links to the application | string | n/a | yes |
| domain | The top level domain name for the organization | string | `""` | no |
| enable\_networking | The flag to toggle the creation of subnets | bool | `"false"` | no |
| enable\_private\_dns | The flag to create private dns zone in shared VPC | bool | `"false"` | no |
| impersonate\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |
| nonprod\_folder\_id | The folder id the non-production where project will be created | string | n/a | yes |
| nonprod\_subnet\_ip\_cidr\_range | The CIDR Range of the subnet to get allocated to the nonprod project | string | `""` | no |
| nonprod\_subnet\_secondary\_ranges | The secondary CIDR Ranges of the subnet to get allocated to the nonprod project | object | `<list>` | no |
| org\_id | The organization id for the associated services | string | n/a | yes |
| prod\_folder\_id | The folder id the production where the project will be created | string | n/a | yes |
| prod\_subnet\_ip\_cidr\_range | The CIDR Range of the subnet to get allocated to the prod project | string | `""` | no |
| prod\_subnet\_secondary\_ranges | The secondary CIDR Ranges of the subnet to get allocated to the prod project | object | `<list>` | no |
| project\_prefix | The name of the GCP project | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
