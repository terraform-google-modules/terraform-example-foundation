# High Availability VPN module

This module implements the recommendation proposed in
[High Availability VPN](https://cloud.google.com/network-connectivity/docs/vpn/concepts/topologies#overview).

If you are not able to use Dedicated Interconnect or Partner Interconnect you can also use an High Availability Cloud VPN to connect the On-Prem to your Google Organization.

## Usage

1. Rename `vpn.tf.example` to `vpn.tf` in the environment folder in `3-networks-hub-and-spoke/envs/<environment>`
1. Create secret for VPN pre-shared key `echo 'MY_PSK' | gcloud secrets create VPN_PSK_SECRET_NAME --project ENV_SECRETS_PROJECT --replication-policy=automatic --data-file=-`
1. Update in the file the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.

**This module only works with two regions.**


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bgp\_peer\_asn | BGP ASN for cloud routes. | `number` | n/a | yes |
| default\_region1 | Default region 1 for Cloud Routers | `string` | n/a | yes |
| default\_region2 | Default region 2 for Cloud Routers | `string` | n/a | yes |
| env\_secret\_project\_id | the environment secrets project ID | `string` | n/a | yes |
| on\_prem\_router\_ip\_address1 | On-Prem Router IP address | `string` | n/a | yes |
| on\_prem\_router\_ip\_address2 | On-Prem Router IP address | `string` | n/a | yes |
| project\_id | VPC Project ID | `string` | n/a | yes |
| region1\_router1\_name | Name of the Router 1 for Region 1 where the attachment resides. | `string` | n/a | yes |
| region1\_router1\_tunnel0\_bgp\_peer\_address | BGP session address for router 1 in region 1 tunnel 0 | `string` | n/a | yes |
| region1\_router1\_tunnel0\_bgp\_peer\_range | BGP session range for router 1 in region 1 tunnel 0 | `string` | n/a | yes |
| region1\_router1\_tunnel1\_bgp\_peer\_address | BGP session address for router 1 in region 1 tunnel 1 | `string` | n/a | yes |
| region1\_router1\_tunnel1\_bgp\_peer\_range | BGP session range for router 1 in region 1 tunnel 1 | `string` | n/a | yes |
| region1\_router2\_name | Name of the Router 2 for Region 1 where the attachment resides. | `string` | n/a | yes |
| region1\_router2\_tunnel0\_bgp\_peer\_address | BGP session address for router 2 in region 1 tunnel 0 | `string` | n/a | yes |
| region1\_router2\_tunnel0\_bgp\_peer\_range | BGP session range for router 2 in region 1 tunnel 0 | `string` | n/a | yes |
| region1\_router2\_tunnel1\_bgp\_peer\_address | BGP session address for router 2 in region 1 tunnel 1 | `string` | n/a | yes |
| region1\_router2\_tunnel1\_bgp\_peer\_range | BGP session range for router 2 in region 1 tunnel 1 | `string` | n/a | yes |
| region2\_router1\_name | Name of the Router 1 for Region 2 where the attachment resides. | `string` | n/a | yes |
| region2\_router1\_tunnel0\_bgp\_peer\_address | BGP session address for router 1 in region 2 tunnel 0 | `string` | n/a | yes |
| region2\_router1\_tunnel0\_bgp\_peer\_range | BGP session range for router 1 in region 2 tunnel 0 | `string` | n/a | yes |
| region2\_router1\_tunnel1\_bgp\_peer\_address | BGP session address for router 1 in region 2 tunnel 2 | `string` | n/a | yes |
| region2\_router1\_tunnel1\_bgp\_peer\_range | BGP session range for router 1 in region 2 tunnel 2 | `string` | n/a | yes |
| region2\_router2\_name | Name of the Router 2 for Region 2 where the attachment resides | `string` | n/a | yes |
| region2\_router2\_tunnel0\_bgp\_peer\_address | BGP session address for router 2 in region 2 tunnel 0 | `string` | n/a | yes |
| region2\_router2\_tunnel0\_bgp\_peer\_range | BGP session range for router 2 in region 2 tunnel 0 | `string` | n/a | yes |
| region2\_router2\_tunnel1\_bgp\_peer\_address | BGP session address for router 2 in region 1 tunnel 1 | `string` | n/a | yes |
| region2\_router2\_tunnel1\_bgp\_peer\_range | BGP session range for router 2 in region 1 tunnel 1 | `string` | n/a | yes |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |
| vpn\_psk\_secret\_name | The name of the secret to retrieve from secret manager. This will be retrieved from the environment secrets project. | `string` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
