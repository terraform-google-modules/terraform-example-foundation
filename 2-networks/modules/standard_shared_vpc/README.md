<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bgp\_asn | BGP ASN for default cloud router. | string | n/a | yes |
| default\_region | Default subnet region standard_shared_vpc currently only configures one region. | string | n/a | yes |
| network\_name | Name for VPC. | string | n/a | yes |
| private\_service\_cidr | CIDR range for private service networking. Used for Cloud SQL and other managed services. | string | n/a | yes |
| project\_id | Project ID for Shared VPC. | string | n/a | yes |
| secondary\_ranges | Secondary ranges that will be used in some of the subnets | object | `<map>` | no |
| subnets | The list of subnets being created | list(map(string)) | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| subnets\_flow\_logs | Whether the subnets have VPC flow logs enabled |
| subnets\_ips | The IPs and CIDRs of the subnets being created |
| subnets\_names | The names of the subnets being created |
| subnets\_private\_access | Whether the subnets have access to Google API's without a public IP |
| subnets\_regions | The region where the subnets will be created |
| subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
