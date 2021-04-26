<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The ID of the access context manager policy the perimeter lies in. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `string` | n/a | yes |
| alert\_pubsub\_topic | The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` | `string` | `null` | no |
| alert\_spent\_percents | A list of percentages of the budget to alert on when threshold is exceeded | `list(number)` | <pre>[<br>  0.5,<br>  0.75,<br>  0.9,<br>  0.95<br>]</pre> | no |
| app\_infra\_pipeline\_cloudbuild\_sa | Cloud Build SA used for deploying infrastructure | `string` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | `string` | n/a | yes |
| budget\_amount | The amount to use as the budget | `number` | `1000` | no |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls. | `bool` | `true` | no |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| gcs\_bucket\_prefix | Name prefix to be used for GCS Bucket | `string` | `"cmek-encrypted-bucket"` | no |
| key\_name | Name to be used for KMS Key | `string` | `"crypto-key-example"` | no |
| key\_rotation\_period | Rotation period in seconds to be used for KMS Key | `string` | `"7776000s"` | no |
| keyring\_name | Name to be used for KMS Keyring | `string` | `"sample-keyring"` | no |
| location\_gcs | Case-Sensitive Location for GCS Bucket (Should be same region as the KMS Keyring) | `string` | `"US"` | no |
| location\_kms | Case-Sensitive Location for KMS Keyring (Should be same region as the GCS Bucket) | `string` | `"us"` | no |
| optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules: IAP SSH, IAP RDP and Internal & Global load balancing health check and load balancing IP ranges. | `bool` | `false` | no |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| peering\_module\_depends\_on | List of modules or resources peering module depends on. | `list` | `[]` | no |
| perimeter\_name | Access context manager service perimeter name to attach the restricted svpc project. | `string` | n/a | yes |
| project\_prefix | Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters. | `string` | `"prj"` | no |
| secrets\_prj\_suffix | Name suffix to use for secrets project created. | `string` | `"env-secrets"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |
| windows\_activation\_enabled | Enable Windows license activation for Windows workloads. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. |
| base\_shared\_vpc\_project | Project sample base project. |
| base\_shared\_vpc\_project\_sa | Project sample base project SA. |
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
| vpc\_service\_control\_perimeter\_name | VPC Service Control name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
