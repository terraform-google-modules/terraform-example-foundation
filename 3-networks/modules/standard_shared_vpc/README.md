<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bgp\_asn | BGP ASN for default cloud router. | `number` | n/a | yes |
| default\_fw\_rules\_enabled | Toggle creation of default firewall rules. | `bool` | `true` | no |
| default\_region | Region used to create cloud router. | `string` | n/a | yes |
| dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for VPC DNS. | `bool` | `true` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization. | `string` | n/a | yes |
| nat\_num\_addresses | Number of external IPs to reserve for Cloud NAT. | `number` | `2` | no |
| private\_service\_cidr | CIDR range for private service networking. Used for Cloud SQL and other managed services. | `string` | n/a | yes |
| project\_id | Project ID for Restricted Shared VPC. | `string` | n/a | yes |
| subnets | The list of subnets being created. Includes the Secondary ranges that will be used in some of the subnets. If you don't have secondary ranges, inform an empty list 'secondary\_ranges = []' | <pre>list(object({<br>    subnet_ip             = string,<br>    subnet_region         = string,<br>    subnet_private_access = string,<br>    subnet_flow_logs      = string,<br>    description           = string,<br>    secondary_ranges = list(object({<br>      range_label   = string,<br>      ip_cidr_range = string<br>    }))<br>  }))</pre> | `[]` | no |
| vpc\_label | Label for VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| allow\_iap\_rdp | Firewall rule allow\_iap\_rdp created in the network |
| allow\_iap\_ssh | Firewall rule allow\_iap\_ssh created in the network |
| allow\_lb | Firewall rule allow\_lb created in the network |
| default\_policy | DNS Policy created in the network |
| dns\_record\_set\_gcr\_api | DNS Record set for GCR APIs |
| dns\_record\_set\_private\_api | DNS Record set for Private APIs |
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
