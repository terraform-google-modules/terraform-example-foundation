# 3-networks-hub-and-spoke/shared

The purpose of this step is to set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones) that will be used by all environments. This step will also create the Network Hubs that are part of the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) setup.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| base\_hub\_dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for Base Hub VPC DNS. | `bool` | `true` | no |
| base\_hub\_dns\_enable\_logging | Toggle DNS logging for Base Hub VPC DNS. | `bool` | `true` | no |
| base\_hub\_firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls in Base Hub VPC. | `bool` | `true` | no |
| base\_hub\_nat\_bgp\_asn | BGP ASN for first NAT cloud routes in Base Hub. | `number` | `64514` | no |
| base\_hub\_nat\_enabled | Toggle creation of NAT cloud router in Base Hub. | `bool` | `false` | no |
| base\_hub\_nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT in Base Hub. | `number` | `2` | no |
| base\_hub\_nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT in Base Hub. | `number` | `2` | no |
| base\_hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Base Hub | `bool` | `false` | no |
| base\_vpc\_flow\_logs | enable\_logging: set to true to enable VPC flow logging for the subnetworks.<br>  aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    enable_logging       = optional(string, "true")<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | `number` | `64667` | no |
| custom\_restricted\_services | List of custom services to be protected by the VPC-SC perimeter. If empty, all supported services (https://cloud.google.com/vpc-service-controls/docs/supported-products) will be protected. | `list(string)` | `[]` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| dns\_vpc\_flow\_logs | enable\_logging: set to true to enable VPC flow logging for the subnetworks.<br>  aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    enable_logging       = optional(string, "true")<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period. | `string` | n/a | yes |
| egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference), each list object has a `from` and `to` value that describes egress\_from and egress\_to.<br><br>Example: `[{ from={ identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| enable\_dedicated\_interconnect | Enable Dedicated Interconnect in the environment. | `bool` | `false` | no |
| enable\_hub\_and\_spoke\_transitivity | Enable transitivity via gateway VMs on Hub-and-Spoke architecture. | `bool` | `false` | no |
| enable\_partner\_interconnect | Enable Partner Interconnect in the environment. | `bool` | `false` | no |
| firewall\_policies\_enable\_logging | Toggle hierarchical firewall logging. | `bool` | `true` | no |
| ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| perimeter\_additional\_members | The list of additional members to be added to the perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`. | `list(string)` | n/a | yes |
| preactivate\_partner\_interconnect | Preactivate Partner Interconnect VLAN attachment in the environment. | `bool` | `false` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| restricted\_hub\_dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for Restricted Hub VPC DNS. | `bool` | `true` | no |
| restricted\_hub\_dns\_enable\_logging | Toggle DNS logging for Restricted Hub VPC DNS. | `bool` | `true` | no |
| restricted\_hub\_firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls in Restricted Hub VPC. | `bool` | `true` | no |
| restricted\_hub\_nat\_bgp\_asn | BGP ASN for first NAT cloud routes in Restricted Hub. | `number` | `64514` | no |
| restricted\_hub\_nat\_enabled | Toggle creation of NAT cloud router in Restricted Hub. | `bool` | `false` | no |
| restricted\_hub\_nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT in Restricted Hub. | `number` | `2` | no |
| restricted\_hub\_nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT in Restricted Hub. | `number` | `2` | no |
| restricted\_hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Restricted Hub. | `bool` | `false` | no |
| restricted\_vpc\_flow\_logs | enable\_logging: set to true to enable VPC flow logging for the subnetworks.<br>  aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    enable_logging       = optional(string, "true")<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |
| target\_name\_server\_addresses | List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones. | `list(map(any))` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| base\_dns\_policy | The name of the DNS policy being created |
| base\_host\_project\_id | The base host project ID |
| base\_network\_name | The name of the VPC being created |
| restricted\_dns\_policy | The name of the DNS policy being created |
| restricted\_host\_project\_id | The restricted host project ID |
| restricted\_network\_name | The name of the VPC being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
