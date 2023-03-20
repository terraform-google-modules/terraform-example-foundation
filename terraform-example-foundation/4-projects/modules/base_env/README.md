<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| business\_code | The business code (ex. bu1). | `string` | n/a | yes |
| business\_unit | The business (ex. business\_unit\_1). | `string` | n/a | yes |
| env | The environment to prepare (ex. development). | `string` | n/a | yes |
| firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls. | `bool` | `true` | no |
| gcs\_bucket\_prefix | Name prefix to be used for GCS Bucket | `string` | `"bkt"` | no |
| key\_name | Name to be used for KMS Key | `string` | `"crypto-key-example"` | no |
| key\_rotation\_period | Rotation period in seconds to be used for KMS Key | `string` | `"7776000s"` | no |
| keyring\_name | Name to be used for KMS Keyring | `string` | `"sample-keyring"` | no |
| location\_gcs | Case-Sensitive Location for GCS Bucket (Should be same region as the KMS Keyring) | `string` | `"US"` | no |
| location\_kms | Case-Sensitive Location for KMS Keyring (Should be same region as the GCS Bucket) | `string` | `"us"` | no |
| optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules: IAP SSH, IAP RDP and Internal & Global load balancing health check and load balancing IP ranges. | `bool` | `false` | no |
| peering\_module\_depends\_on | List of modules or resources peering module depends on. | `list(any)` | `[]` | no |
| project\_budget | Budget configuration.<br>  budget\_amount: The amount to use as the budget.<br>  alert\_spent\_percents: A list of percentages of the budget to alert on when threshold is exceeded.<br>  alert\_pubsub\_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`. | <pre>object({<br>    budget_amount        = optional(number, 1000)<br>    alert_spent_percents = optional(list(number), [0.5, 0.75, 0.9, 0.95])<br>    alert_pubsub_topic   = optional(string, null)<br>  })</pre> | `{}` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| secrets\_prj\_suffix | Name suffix to use for secrets project created. | `string` | `"env-secrets"` | no |
| windows\_activation\_enabled | Enable Windows license activation for Windows workloads. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. |
| base\_shared\_vpc\_project | Project sample base project. |
| base\_shared\_vpc\_project\_sa | Project sample base project SA. |
| base\_subnets\_self\_links | The self-links of subnets from base environment. |
| bucket | The created storage bucket |
| env\_secrets\_project | Project sample peering project id. |
| floating\_project | Project sample floating project. |
| keyring | The name of the keyring. |
| keys | List of created key names. |
| peering\_complete | Output to be used as a module dependency. |
| peering\_network | Peer network peering resource. |
| peering\_project | Project sample peering project id. |
| restricted\_enabled\_apis | Activated APIs. |
| restricted\_shared\_vpc\_project | Project sample restricted project id. |
| restricted\_shared\_vpc\_project\_number | Project sample restricted project. |
| restricted\_subnets\_self\_links | The self-links of subnets from restricted environment. |
| vpc\_service\_control\_perimeter\_name | VPC Service Control name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
