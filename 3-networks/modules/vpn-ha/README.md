# High Availability VPN module

This module implementes the recomendation proposed in
[High Availability VPN](https://cloud.google.com/network-connectivity/docs/vpn/concepts/topologies#overview).

## Prerequisites

1. Execution of at least one of the environments in `3-networks/env/`.
1. Creation on two Cloud Routers for each Region. Both the `Restricted shared VPC`
and the `Standard shared VPC` modules create two Cloud Routers for each Region
that should be used as input for this module. **This module only works with two regions.**

## Usage

For each environmnet and for each network, you should add the following peace of code in the
`envs/<environment>/main.tf`

```hcl
module "shared_<private/restricted>_vpn" {
  source = "../../modules/vpn-ha"

  project_id = local.<private/restricted>_project_id
  default_region1 = var.default_region1
  default_region2 = var.default_region2
  vpc_label = "<private/restricted>"
  environment_code = ${local.environment_code}

  bgp_peer_secret = "<my-secret-value>"

  on_prem_router_ip_address1 = "8.8.8.8" # on-prem router ip address
  on_prem_router_ip_address2 = "8.8.8.8" # on-prem router ip address

  bgp_peer_asn = "64515"

  # tunnel 0
  bgp_peer_address0 = "169.254.1.1"
  bgp_peer_range0 = "169.254.1.2/30"

  # tunnel 1
  bgp_peer_address1 = "169.254.2.1"
  bgp_peer_range1 = "169.254.2.2/30"

  # tunnel 2
  bgp_peer_address2 = "169.254.4.1"
  bgp_peer_range2 = "169.254.4.2/30"

  # tunnel 3
  bgp_peer_address3 = "169.254.6.1"
  bgp_peer_range3 = "169.254.6.2/30"

  # tunnel 4
  bgp_peer_address4 = "169.254.8.1"
  bgp_peer_range4 = "169.254.8.2/30"

  # tunnel 5
  bgp_peer_address5 = "169.254.10.1"
  bgp_peer_range5 = "169.254.10.2/30"

  # tunnel 6
  bgp_peer_address6 = "169.254.12.1"
  bgp_peer_range6 = "169.254.12.2/30"

  # tunnel 7
  bgp_peer_address7 = "169.254.14.1"
  bgp_peer_range7 = "169.254.14.2/30"
}
```

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
