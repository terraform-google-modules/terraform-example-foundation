<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bgp\_asn\_subnet | BGP ASN for Subnets cloud routers. | number | n/a | yes |
| default\_region1 | First subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| default\_region2 | Second subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for VPC DNS. | bool | `"true"` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | bool | `"true"` | no |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization. | string | n/a | yes |
| members | An allowed list of members (users, service accounts). The signed-in identity originating the request must be a part of one of the provided members. If not specified, a request may come from any user (logged in/not logged in, etc.). Formats: user:{emailid}, serviceAccount:{emailid} | list(string) | n/a | yes |
| nat\_bgp\_asn\_region1 | BGP ASN for first NAT cloud routes. | number | `"0"` | no |
| nat\_bgp\_asn\_region2 | BGP ASN for second NAT cloud routes. | number | `"0"` | no |
| nat\_enabled | Toggle creation of NAT cloud router. | bool | `"false"` | no |
| nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT. | number | `"2"` | no |
| nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT. | number | `"2"` | no |
| optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules. | bool | `"false"` | no |
| org\_id | Organization ID | string | n/a | yes |
| policy\_name | The access context policy's name. | string | n/a | yes |
| private\_service\_cidr | CIDR range for private service networking. Used for Cloud SQL and other managed services. | string | n/a | yes |
| project\_id | Project ID for Restricted Shared VPC. | string | n/a | yes |
| project\_number | Project number for Restricted Shared VPC. It is the project INSIDE the regular service perimeter. | number | n/a | yes |
| restricted\_services | List of services to restrict. | list(string) | n/a | yes |
| secondary\_ranges | Secondary ranges that will be used in some of the subnets | object | `<map>` | no |
| subnets | The list of subnets being created | list(map(string)) | `<list>` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| subnets\_ips | The IPs and CIDRs of the subnets being created |
| subnets\_names | The names of the subnets being created |
| subnets\_regions | The region where the subnets will be created |
| subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
