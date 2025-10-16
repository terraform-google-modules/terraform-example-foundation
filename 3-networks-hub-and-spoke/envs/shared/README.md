# 3-networks-hub-and-spoke/shared

The purpose of this step is to set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones) that will be used by all environments. This step will also create the Network Hubs that are part of the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) setup.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | `number` | `64667` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| dns\_vpc\_flow\_logs | enable\_logging: set to true to enable VPC flow logging for the subnetworks.<br>  aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    enable_logging       = optional(string, "true")<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period. | `string` | n/a | yes |
| enable\_dedicated\_interconnect | Enable Dedicated Interconnect in the environment. | `bool` | `false` | no |
| enable\_hub\_and\_spoke\_transitivity | Enable transitivity via gateway VMs on Hub-and-Spoke architecture. | `bool` | `false` | no |
| enable\_partner\_interconnect | Enable Partner Interconnect in the environment. | `bool` | `false` | no |
| firewall\_policies\_enable\_logging | Toggle hierarchical firewall logging. | `bool` | `true` | no |
| hub\_dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for Shared Hub VPC DNS. | `bool` | `true` | no |
| hub\_dns\_enable\_logging | Toggle DNS logging for Shared Hub VPC DNS. | `bool` | `true` | no |
| hub\_firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls in Shared Hub VPC. | `bool` | `true` | no |
| hub\_nat\_bgp\_asn | BGP ASN for first NAT cloud routes in Shared Hub. | `number` | `64514` | no |
| hub\_nat\_enabled | Toggle creation of NAT cloud router in Shared Hub. | `bool` | `false` | no |
| hub\_nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT in Shared Hub. | `number` | `2` | no |
| hub\_nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT in Shared Hub. | `number` | `2` | no |
| hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Shared Hub. | `bool` | `false` | no |
| preactivate\_partner\_interconnect | Preactivate Partner Interconnect VLAN attachment in the environment. | `bool` | `false` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| target\_name\_server\_addresses | List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones. | `list(map(any))` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |
| vpc\_flow\_logs | enable\_logging: set to true to enable VPC flow logging for the subnetworks.<br>  aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    enable_logging       = optional(string, "true")<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| dns\_policy | The name of the DNS policy being created |
| network\_name | The name of the Shared VPC being created |
| shared\_vpc\_host\_project\_id | The host project ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
