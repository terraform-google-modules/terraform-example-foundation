<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bgp\_asn | BGP ASN for cloud routes. | number | `"0"` | no |
| default\_region1 | Default region 1 for Cloud Routers | string | n/a | yes |
| default\_region2 | Default region 2 for Cloud Routers | string | n/a | yes |
| network\_name | Network Name | string | n/a | yes |
| on\_prem\_ip\_address | On-Prem IP address | string | n/a | yes |
| region1\_router1\_name | Cloud Router 1 name for region 1 | string | n/a | yes |
| region1\_router2\_name | Cloud Router 2 name for region 1 | string | n/a | yes |
| region2\_router1\_name | Cloud Router 1 name for region 2 | string | n/a | yes |
| region2\_router2\_name | Cloud Router 2 name for region 2 | string | n/a | yes |
| remote0\_ip | Remote 0 IP | string | n/a | yes |
| remote0\_range | Remote 0 IP range | string | n/a | yes |
| remote0\_secret | Remote 0 secret name | string | n/a | yes |
| remote1\_ip | Remote 1 IP | string | n/a | yes |
| remote1\_range | Remote 1 IP range | string | n/a | yes |
| remote1\_secret | Remote 1 secret name | string | n/a | yes |
| vpc\_name | VPC Name | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
