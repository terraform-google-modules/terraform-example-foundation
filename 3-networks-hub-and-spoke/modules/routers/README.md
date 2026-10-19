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
| project\_id | Project ID to create the routers. | `string` | n/a | yes |
| router\_config | Cloud Routers configuration map containing router definitions.<br><br>Top-level attributes:<br>  - bgp\_asn:              Default BGP Autonomous System Number (ASN) for the Cloud Routers.<br>  - advertised\_groups:    (Optional) Default list of advertised groups (defaults to ["ALL\_SUBNETS"]).<br>  - advertised\_ip\_ranges: (Optional) Default list of custom IP ranges to advertise.<br>  - routers:              Map of Cloud Router objects keyed by a unique identifier.<br><br>Router attributes (map values):<br>  - region:    Google Cloud region where the Cloud Router resides.<br>  - cr\_suffix: Suffix used for router naming (e.g., 'cr1', 'cr2'). | <pre>object({<br>    bgp_asn           = number<br>    advertised_groups = optional(list(string), ["ALL_SUBNETS"])<br>    advertised_ip_ranges = optional(list(object({<br>      range       = string<br>      description = optional(string)<br>    })), [])<br>    routers = map(object({<br>      region    = string<br>      cr_suffix = string<br>    }))<br>  })</pre> | n/a | yes |
| vpc\_name | Label to identify the VPC associated with VPC that will use the Routers. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| router\_ids | Map of Cloud Router IDs keyed by router identifier. |
| router\_names | Map of Cloud Router names keyed by router identifier. |
| routers | Map of all created Cloud Router module instances keyed by router identifier. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
