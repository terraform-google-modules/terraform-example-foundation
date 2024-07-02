<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| business\_code | The business code (ex. bu1). | `string` | n/a | yes |
| business\_unit | The business (ex. business\_unit\_1). | `string` | n/a | yes |
| env | The environment to prepare (ex. development). | `string` | n/a | yes |
| firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls. | `bool` | `true` | no |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| gcs\_bucket\_prefix | Name prefix to be used for GCS Bucket | `string` | `"bkt"` | no |
| gcs\_custom\_placement\_config | Configuration of the bucket's custom location in a dual-region bucket setup. If the bucket is designated a single or multi-region, the variable are null. | <pre>object({<br>    data_locations = list(string)<br>  })</pre> | n/a | yes |
| key\_name | Name to be used for KMS Key | `string` | `"crypto-key-example"` | no |
| key\_rotation\_period | Rotation period in seconds to be used for KMS Key | `string` | `"7776000s"` | no |
| keyring\_name | Name to be used for KMS Keyring | `string` | `"sample-keyring"` | no |
| kms\_prj\_suffix | Name suffix to use for KMS project created. | `string` | `"kms"` | no |
| location\_gcs | Case-Sensitive Location for GCS Bucket (Should be same region as the KMS Keyring) | `string` | n/a | yes |
| location\_kms | Case-Sensitive Location for KMS Keyring (Should be same region as the GCS Bucket) | `string` | n/a | yes |
| optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules: Internal & Global load balancing health check and load balancing IP ranges. | `bool` | `false` | no |
| peering\_iap\_fw\_rules\_enabled | Toggle creation of optional IAP firewall rules: SSH, RDP. | `bool` | `false` | no |
| peering\_module\_depends\_on | List of modules or resources peering module depends on. | `list(any)` | `[]` | no |
| project\_budget | Budget configuration.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.<br>  alert\_spend\_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default). | <pre>object({<br>    budget_amount        = optional(number, 1000)<br>    alert_spent_percents = optional(list(number), [1.2])<br>    alert_pubsub_topic   = optional(string, null)<br>    alert_spend_basis    = optional(string, "FORECASTED_SPEND")<br>  })</pre> | `{}` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| subnet\_ip\_range | IP range for the peered subnetwork. If "peering\_iap\_fw\_rules\_enabled" is true, this field should not be null. | `string` | `null` | no |
| subnet\_region | Region which the peered subnet will be created. If "peering\_iap\_fw\_rules\_enabled" is true, this field should not be null. | `string` | `null` | no |
| tfc\_org\_name | Name of the TFC organization | `string` | n/a | yes |
| vpc\_flow\_logs | aggregation\_interval: Toggles the aggregation interval for collecting flow logs. Increasing the interval time will reduce the amount of generated flow logs for long lasting connections. Possible values are: INTERVAL\_5\_SEC, INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, INTERVAL\_15\_MIN.<br>  flow\_sampling: Set the sampling rate of VPC flow logs within the subnetwork where 1.0 means all collected logs are reported and 0.0 means no logs are reported. The value of the field must be in [0, 1].<br>  metadata: Configures whether metadata fields should be added to the reported VPC flow logs. Possible values are: EXCLUDE\_ALL\_METADATA, INCLUDE\_ALL\_METADATA, CUSTOM\_METADATA.<br>  metadata\_fields: ist of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and "metadata" is set to CUSTOM\_METADATA.<br>  filter\_expr: Export filter used to define which VPC flow logs should be logged, as as CEL expression. See https://cloud.google.com/vpc/docs/flow-logs#filtering for details on how to format this field. | <pre>object({<br>    aggregation_interval = optional(string, "INTERVAL_5_SEC")<br>    flow_sampling        = optional(string, "0.5")<br>    metadata             = optional(string, "INCLUDE_ALL_METADATA")<br>    metadata_fields      = optional(list(string), [])<br>    filter_expr          = optional(string, "true")<br>  })</pre> | `{}` | no |
| vpc\_service\_control\_attach\_dry\_run | Whether the project will be attached to a VPC Service Control Perimeter with an explicit dry run spec flag, which may use different values for the dry run perimeter compared to the ENFORCED perimeter. | `bool` | `false` | no |
| vpc\_service\_control\_attach\_enabled | Whether the project will be attached to a VPC Service Control Perimeter in ENFORCED MODE. | `bool` | `false` | no |
| windows\_activation\_enabled | Enable Windows license activation for Windows workloads. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. |
| base\_shared\_vpc\_project | Project sample base project. |
| base\_shared\_vpc\_project\_sa | Project sample base project SA. |
| base\_subnets\_self\_links | The self-links of subnets from base environment. |
| bucket | The created storage bucket. |
| floating\_project | Project sample floating project. |
| iap\_firewall\_tags | The security tags created for IAP (SSH and RDP) firewall rules and to be used on the VM created on step 5-app-infra on the peering network project. |
| keyring | The name of the keyring. |
| keys | List of created key names. |
| peering\_complete | Output to be used as a module dependency. |
| peering\_network | Peer network peering resource. |
| peering\_project | Project sample peering project id. |
| peering\_subnetwork\_self\_link | The subnetwork self link of the peering network. |
| restricted\_enabled\_apis | Activated APIs. |
| restricted\_shared\_vpc\_project | Project sample restricted project id. |
| restricted\_shared\_vpc\_project\_number | Project sample restricted project. |
| restricted\_subnets\_self\_links | The self-links of subnets from restricted environment. |
| vpc\_service\_control\_perimeter\_name | VPC Service Control name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
