<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| folder\_deletion\_protection | Prevent Terraform from destroying or recreating the folder. | `string` | `true` | no |
| gcs\_custom\_placement\_config | Configuration of the bucket's custom location in a dual-region bucket setup. If the bucket is designated a single or multi-region, the variable are null. | <pre>object({<br>    data_locations = list(string)<br>  })</pre> | `null` | no |
| instance\_region | Region which the peered subnet will be created (Should be same region as the VM that will be created on step 5-app-infra on the peering project). | `string` | `null` | no |
| location\_gcs | Case-Sensitive Location for GCS Bucket (Should be same region as the KMS Keyring) | `string` | `null` | no |
| location\_kms | Case-Sensitive Location for KMS Keyring (Should be same region as the GCS Bucket) | `string` | `null` | no |
| peering\_module\_depends\_on | List of modules or resources peering module depends on. | `list(any)` | `[]` | no |
| project\_deletion\_policy | The deletion policy for the project created. | `string` | `"PREVENT"` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. |
| bucket | The created storage bucket. |
| default\_region | The default region for the project. |
| floating\_project | Project sample floating project. |
| iap\_firewall\_tags | The security tags created for IAP (SSH and RDP) firewall rules and to be used on the VM created on step 5-app-infra on the peering network project. |
| keyring | The name of the keyring. |
| keys | List of created key names. |
| peering\_complete | Output to be used as a module dependency. |
| peering\_network | Peer network peering resource. |
| peering\_project | Project sample peering project id. |
| peering\_project\_number | Project sample shared vpc project. |
| peering\_subnetwork\_self\_link | The subnetwork self link of the peering network. |
| restricted\_enabled\_apis | Activated APIs. |
| shared\_vpc\_project | Project sample shared vpc project id. |
| shared\_vpc\_project\_number | Project sample shared vpc project. |
| subnets\_self\_links | The self-links of subnets from shared vpc environment. |
| vpc\_service\_control\_perimeter\_name | VPC Service Control name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
