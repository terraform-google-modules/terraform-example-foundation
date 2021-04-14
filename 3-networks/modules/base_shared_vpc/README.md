<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allow\_all\_egress\_ranges | List of network ranges to which all egress traffic will be allowed | `any` | `null` | no |
| allow\_all\_ingress\_ranges | List of network ranges from which all ingress traffic will be allowed | `any` | `null` | no |
| bgp\_asn\_subnet | BGP ASN for Subnets cloud routers. | `number` | n/a | yes |
| default\_region1 | Default region 1 for subnets and Cloud Routers | `string` | n/a | yes |
| default\_region2 | Default region 2 for subnets and Cloud Routers | `string` | n/a | yes |
| dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for VPC DNS. | `bool` | `true` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| domain | The DNS name of peering managed zone, for instance 'example.com.' | `string` | n/a | yes |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization. | `string` | n/a | yes |
| firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls. | `bool` | `true` | no |
| folder\_prefix | Name prefix to use for folders created. | `string` | `"fldr"` | no |
| mode | Network deployment mode, should be set to `hub` or `spoke` when `enable_hub_and_spoke` architecture chosen, keep as `null` otherwise. | `string` | `null` | no |
| nat\_bgp\_asn | BGP ASN for first NAT cloud routes. | `number` | `0` | no |
| nat\_enabled | Toggle creation of NAT cloud router. | `bool` | `false` | no |
| nat\_num\_addresses | Number of external IPs to reserve for Cloud NAT. | `number` | `2` | no |
| nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT. | `number` | `2` | no |
| nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT. | `number` | `2` | no |
| optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules: IAP SSH, IAP RDP and Internal & Global load balancing health check and load balancing IP ranges. | `bool` | `false` | no |
| org\_id | Organization ID | `string` | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | `string` | `""` | no |
| private\_service\_cidr | CIDR range for private service networking. Used for Cloud SQL and other managed services. | `string` | `null` | no |
| project\_id | Project ID for Private Shared VPC. | `string` | n/a | yes |
| secondary\_ranges | Secondary ranges that will be used in some of the subnets | `map(list(object({ range_name = string, ip_cidr_range = string })))` | `{}` | no |
| subnets | The list of subnets being created | `list(map(string))` | `[]` | no |
| windows\_activation\_enabled | Enable Windows license activation for Windows workloads. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| region1\_router1 | Router 1 for Region 1 |
| region1\_router2 | Router 2 for Region 1 |
| region2\_router1 | Router 1 for Region 2 |
| region2\_router2 | Router 2 for Region 2 |
| subnets\_flow\_logs | Whether the subnets have VPC flow logs enabled |
| subnets\_ips | The IPs and CIDRs of the subnets being created |
| subnets\_names | The names of the subnets being created |
| subnets\_private\_access | Whether the subnets have access to Google API's without a public IP |
| subnets\_regions | The region where the subnets will be created |
| subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
