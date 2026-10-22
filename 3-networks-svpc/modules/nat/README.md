# Network NAT module

This module creates Routers and NAT Routers for each region provided of the given Network

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| nat\_config | Configuration for Cloud NAT and underlying Cloud Routers.<br>Attributes:<br>- create\_internet\_route: Set to true to create the default internet route.<br>- create\_egress\_firewall: Set to true to create the egress firewall rule.<br>- allow\_udp\_dns:  Set to true to allow outbound UDP DNS resolution traffic (port 53) in the egress firewall rule.<br>- egress\_tcp\_ports: List of TCP ports to allow outbound in the egress firewall rule.<br>- allow\_icmp: Set to true to allow ICMP traffic in the egress firewall rule.<br>- egress\_tags: Network tags used for routing internet egress traffic.<br>- bgp\_asn: The BGP Autonomous System Number assigned to the Cloud Router.<br>- egress\_internet\_route\_priority: Route priority.<br>- egress\_firewall\_priority: Firewall rule priority.<br>- regions: Defines which regions get a NAT router.<br>  - name: The GCP region name (e.g., "us-central1") where the router and NAT will be deployed.<br>  - num\_addresses: The number of static external IP addresses to manually allocate and assign to the NAT gateway in this region. | <pre>object({<br>    create_internet_route          = optional(bool, true)<br>    create_egress_firewall         = optional(bool, true)<br>    egress_tcp_ports               = optional(list(string), ["443"])<br>    allow_udp_dns                  = optional(bool, true)<br>    allow_icmp                     = optional(bool, true)<br>    egress_tags                    = optional(list(string), ["egress-internet"])<br>    bgp_asn                        = optional(number, 64512)<br>    egress_internet_route_priority = optional(number, 1000)<br>    egress_firewall_priority       = optional(number, 1000)<br>    regions = optional(list(object({<br>      name          = string<br>      num_addresses = optional(number, 2)<br>    })))<br>  })</pre> | `{}` | no |
| network\_self\_link | Target Network self link. | `string` | n/a | yes |
| project\_id | Project ID for VPC. | `string` | n/a | yes |
| resource\_code | Standardized grouping code used to categorize resources by their environment (e.g., 'p' for production) or their architectural/topology role (e.g., 'h' for hub, 's' for spoke). Used as an infix in resource names (e.g., cr-p-svpc-us-central1-nat-router) | `string` | n/a | yes |
| vpc\_name | The name of the network. To be used to compose names of resources like `cr-{vpc_name}` | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_router\_ids | Map of Cloud Router IDs created, keyed by region. |
| cloud\_router\_names | Map of Cloud Router names created, keyed by region. |
| nat\_ip\_address\_list | A flat list of all external IP addresses reserved for NAT. Very useful for third-party firewall allowlisting. |
| nat\_ip\_addresses\_map | A map of NAT external IP addresses with their keys, useful if you need to know which IP belongs to which region/index. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
