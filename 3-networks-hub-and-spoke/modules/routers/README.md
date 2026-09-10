# Network Routers module

This module creates 4 routers, 2 for each region to be used by Dedicated Interconnect, Partner Interconnect, or High Availability Cloud VPN to connect the On-Prem to your Google Organization .


## Usage

1. Rename `routers.tf.example` to `routers.tf` in the environment folder in `3-networks-hub-and-spoke/envs/shared`
1. Verify other default values are valid for your environment.

**This module only works with two regions.**


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| advertised\_ip\_ranges | User-specified list of individual IP ranges to advertise. | <pre>list(object({<br>    range       = string<br>    description = optional(string)<br>  }))</pre> | `[]` | no |
| bgp\_asn\_subnet | BGP ASN for Subnets cloud routers. | `number` | n/a | yes |
| project\_id | project ID to create the routers. | `string` | n/a | yes |
| region1 | First subnet region. | `string` | n/a | yes |
| region2 | Second subnet region. | `string` | n/a | yes |
| vpc\_name | Label to identify the VPC associated with VPC that will use the Routers. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| region1\_router1 | Router 1 for Region 1 |
| region1\_router2 | Router 2 for Region 1 |
| region2\_router1 | Router 1 for Region 2 |
| region2\_router2 | Router 2 for Region 2 |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
