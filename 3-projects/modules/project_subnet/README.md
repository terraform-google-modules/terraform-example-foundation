<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application\_name | Name for subnets | string | n/a | yes |
| default\_region | Default region for resources. | string | `"australia-southeast1"` | no |
| enable\_networking | The Flag to toggle the creation of subnets | bool | `"false"` | no |
| enable\_private\_access | Flag to enable Google Private access in the subnet. | bool | `"true"` | no |
| enable\_vpc\_flow\_logs | Flag to enable VPC flow logs with default configuration. | bool | `"false"` | no |
| ip\_cidr\_range | CIDR Block to use for the subnet. | string | n/a | yes |
| project\_id | Project Id | string | n/a | yes |
| secondary\_ranges | Secondary ranges that will be used in some of the subnets | object | `<list>` | no |
| vpc\_host\_project\_id | VPC Host project ID. | string | n/a | yes |
| vpc\_self\_link | Self link for VPC to create the subnet in. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
