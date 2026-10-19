# High Availability VPN module

This module implements the recommendation proposed in
[High Availability VPN](https://cloud.google.com/network-connectivity/docs/vpn/concepts/topologies#overview).

If you are not able to use Dedicated Interconnect or Partner Interconnect you can also use an High Availability Cloud VPN to connect the On-Prem to your Google Organization.

## Usage

1. Rename `routers.tf.example` to `routers..tf` in the shared envs folder in `3-networks-hub-and-spoke/envs/shared`
1. Rename `vpn.tf.example` to `vpn.tf` in the environment folder in `3-networks-hub-and-spoke/envs/shared`
1. Create secret for VPN pre-shared key `echo 'MY_PSK' | gcloud secrets create VPN_PSK_SECRET_NAME --project ORG_SECRETS_PROJECT --replication-policy=automatic --data-file=-`
1. Update in the file the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.

**This module only works with two regions.**


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| env\_secret\_project\_id | Project ID where Secret Manager holds the PSK secret. | `string` | n/a | yes |
| ha\_vpn\_config | HA VPN configuration map containing gateway definitions.<br><br>Top-level attributes:<br>  - gateways: Map of HA VPN gateway objects keyed by a unique identifier.<br><br>Gateway attributes (map values):<br>  - region:                           Google Cloud region where the HA VPN gateway and Cloud Router reside.<br>  - router:                           Name of the Google Cloud Router.<br>  - cr\_suffix:                        Suffix used for gateway naming (e.g., 'cr1', 'cr2').<br>  - peer\_external\_gateway\_interfaces: List of on-premises / external peer IP addresses.<br>  - tunnels:                          Map of tunnel configurations (keyed by tunnel index or identifier). | <pre>object({<br>    gateways = map(object({<br>      region                           = string<br>      router                           = string<br>      cr_suffix                        = string<br>      peer_external_gateway_interfaces = list(string)<br>      tunnels = map(object({<br>        bgp_peer_address  = string<br>        bgp_peer_asn      = number<br>        bgp_session_range = string<br>      }))<br>    }))<br>  })</pre> | n/a | yes |
| ncc\_hub\_group | Network Connectivity Center Group name to attach spokes to. | `string` | n/a | yes |
| ncc\_hub\_uri | The full URI of the existing Network Connectivity Center Hub. | `string` | n/a | yes |
| project\_id | VPC Project ID where HA VPN gateways will be created. | `string` | n/a | yes |
| site\_to\_site\_data\_transfer | Set to true to allow Google Cloud routing to act as a transit network between on-premises sites. | `bool` | `false` | no |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the HA VPN. | `string` | n/a | yes |
| vpn\_psk\_secret\_name | Name of the pre-shared key secret in Secret Manager. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ncc\_vpn\_spoke\_ids | Map of Network Connectivity Center VPN spoke IDs keyed by region. |
| vpn\_gateways | Map of all HA VPN gateway module instances. |
| vpn\_tunnel\_self\_links | Map of VPN tunnel self links grouped by gateway key. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
