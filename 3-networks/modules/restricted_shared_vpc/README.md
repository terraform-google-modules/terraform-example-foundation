<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | number | n/a | yes |
| bgp\_asn\_subnet | BGP ASN for Subnets cloud routers. | number | n/a | yes |
| default\_region1 | First subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| default\_region2 | Second subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for VPC DNS. | bool | `"true"` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | bool | `"true"` | no |
| domain | The DNS name of peering managed zone, for instance 'example.com.' | string | n/a | yes |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization. | string | n/a | yes |
| firewall\_enable\_logging | Toggle firewall logginglogging for VPC Firewalls. | bool | `"true"` | no |
| members | An allowed list of members (users, service accounts). The signed-in identity originating the request must be a part of one of the provided members. If not specified, a request may come from any user (logged in/not logged in, etc.). Formats: user:{emailid}, serviceAccount:{emailid} | list(string) | n/a | yes |
| nat\_bgp\_asn | BGP ASN for NAT cloud routes. If NAT is enabled this variable value must be a value in ranges [64512..65534] or [4200000000..4294967294]. | number | `"64512"` | no |
| nat\_enabled | Toggle creation of NAT cloud router. | bool | `"false"` | no |
| nat\_num\_addresses\_region1 | Number of external IPs to reserve for region 1 Cloud NAT. | number | `"2"` | no |
| nat\_num\_addresses\_region2 | Number of external IPs to reserve for region 2 Cloud NAT. | number | `"2"` | no |
| optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules. | bool | `"false"` | no |
| org\_id | Organization ID | string | n/a | yes |
| private\_service\_cidr | CIDR range for private service networking. Used for Cloud SQL and other managed services. | string | n/a | yes |
| project\_id | Project ID for Restricted Shared VPC. | string | n/a | yes |
| project\_number | Project number for Restricted Shared VPC. It is the project INSIDE the regular service perimeter. | number | n/a | yes |
| restricted\_services | List of services to restrict. | list(string) | n/a | yes |
| secondary\_ranges | Secondary ranges that will be used in some of the subnets | object | `<map>` | no |
| subnets | The list of subnets being created | list(map(string)) | `<list>` | no |
| windows\_activation\_enabled | Enable Windows license activation for Windows workloads. | bool | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| network\_name | The name of the VPC being created |
| network\_self\_link | The URI of the VPC being created |
| region1\_router1 | Router 1 for Region 1 |
| region1\_router2 | Router 2 for Region 1 |
| region2\_router1 | Router 1 for Region 2 |
| region2\_router2 | Router 2 for Region 2 |
| subnets\_ips | The IPs and CIDRs of the subnets being created |
| subnets\_names | The names of the subnets being created |
| subnets\_regions | The region where the subnets will be created |
| subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
