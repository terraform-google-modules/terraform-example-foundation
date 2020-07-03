<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| org\_id | Organization ID | string | n/a | yes |
| subnet\_region1 | First subnet region. The shared vpc modules only configures exactly two regions. | string | n/a | yes |
| subnet\_region2 | Second subnet region. The shared vpc modules only configures exactly two regions. | string | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| restricted\_allow\_iap\_rdp | Firewall rule allow_iap_rdp created in the network |
| restricted\_allow\_iap\_ssh | Firewall rule allow_iap_ssh created in the network |
| restricted\_allow\_lb | Firewall rule allow_lb created in the network |
| restricted\_default\_policy | DNS Policy created in the network |
| restricted\_dns\_record\_set\_gcr\_api | DNS Record set for GCR APIs |
| restricted\_dns\_record\_set\_restricted\_api | DNS Record set for Restricted APIs |
| restricted\_host\_project\_id | The restricted host project ID |
| restricted\_network\_name | The name of the VPC being created |
| restricted\_network\_self\_link | The URI of the VPC being created |
| restricted\_region1\_router1 | Router 1 for Region 1 |
| restricted\_region1\_router2 | Router 1 for Region 2 |
| restricted\_region2\_router1 | Router 2 for Region 1 |
| restricted\_region2\_router2 | Router 2 for Region 2 |
| restricted\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| restricted\_subnets\_names | The names of the subnets being created |
| restricted\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| restricted\_subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
