# 3-networks-dual-svpc/shared

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | `number` | `64667` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period. | `string` | n/a | yes |
| firewall\_policies\_enable\_logging | Toggle hierarchical firewall logging. | `bool` | `true` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |
| vpc\_flow\_logs | enable\_logging: set to true to enable VPC flow logging for the subnetworks.<br>  aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    enable_logging       = optional(string, "true")<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
