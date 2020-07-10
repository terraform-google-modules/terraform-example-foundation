# High Availability VPN module

This module implementes the recomendation proposed in [High Availability VPN](https://cloud.google.com/network-connectivity/docs/how-to/how-to-choose#cloud-vpn).

## Prerequisites

1. Execution of at least one of the environments in `3-networks/env/`.
1. Creation on two Cloud Routers for each Region. Both the `Restricted shared VPC` and the `Standard shared VPC` modules create two Cloud Routers for each Region that should be used as input for this module. **This module only works with two regions.**

## Usage

Sections with examples of calls to this module are commented in each one of the environments. Uncomment these section and update the input values with your interconnects and peer BGP information and rerun Terraform.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bgp\_peer\_address0 | Remote 0 IP | string | n/a | yes |
| bgp\_peer\_address1 | Remote 1 IP | string | n/a | yes |
| bgp\_peer\_address2 | Remote 2 IP | string | n/a | yes |
| bgp\_peer\_address3 | Remote 3 IP | string | n/a | yes |
| bgp\_peer\_address4 | Remote 4 IP | string | n/a | yes |
| bgp\_peer\_address5 | Remote 5 IP | string | n/a | yes |
| bgp\_peer\_address6 | Remote 6 IP | string | n/a | yes |
| bgp\_peer\_address7 | Remote 7 IP | string | n/a | yes |
| bgp\_peer\_asn | BGP ASN for cloud routes. | number | n/a | yes |
| bgp\_peer\_range0 | Remote 0 IP range | string | n/a | yes |
| bgp\_peer\_range1 | Remote 1 IP range | string | n/a | yes |
| bgp\_peer\_range2 | Remote 2 IP range | string | n/a | yes |
| bgp\_peer\_range3 | Remote 3 IP range | string | n/a | yes |
| bgp\_peer\_range4 | Remote 4 IP range | string | n/a | yes |
| bgp\_peer\_range5 | Remote 5 IP range | string | n/a | yes |
| bgp\_peer\_range6 | Remote 6 IP range | string | n/a | yes |
| bgp\_peer\_range7 | Remote 7 IP range | string | n/a | yes |
| bgp\_peer\_secret | Shared secret used to set the secure session between the Cloud VPN gateway and the peer VPN gateway. | string | n/a | yes |
| default\_region1 | Default region 1 for Cloud Routers | string | n/a | yes |
| default\_region2 | Default region 2 for Cloud Routers | string | n/a | yes |
| environment\_code | A short form of the folder level resources (environment) within the Google Cloud organization. | string | n/a | yes |
| on\_prem\_router\_ip\_address1 | On-Prem Router IP address | string | n/a | yes |
| on\_prem\_router\_ip\_address2 | On-Prem Router IP address | string | n/a | yes |
| project\_id | VPC Project ID | string | n/a | yes |
| vpc\_label | Label for VPC. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
