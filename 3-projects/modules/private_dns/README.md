<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application\_name | Friendly application name to apply as a label. | string | n/a | yes |
| enable\_private\_dns | Flag to toggle the creation of dns zones | bool | `"true"` | no |
| environment | Environment to look up VPC and host project. | string | n/a | yes |
| project\_id | Project ID for VPC. | string | n/a | yes |
| shared\_vpc\_project\_id | Project ID for Shared VPC. | string | n/a | yes |
| shared\_vpc\_self\_link | Self link of Shared VPC Network. | string | n/a | yes |
| top\_level\_domain | The top level domain name for the organization | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
