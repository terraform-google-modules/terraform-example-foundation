<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| folder\_prefix | Name prefix to use for folders created. | `string` | `"fldr"` | no |
| instance\_region | The region where compute instance will be created. A subnetwork must exists in the instance region. | `string` | n/a | yes |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | `string` | `""` | no |
| project\_service\_account | Service account email of the account created on step 4-project for the project where the GCE will be created | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| instances\_details | List of details for compute instances |
| instances\_names | List of names for compute instances |
| instances\_self\_links | List of self-links for compute instances |
| instances\_zones | List of zone for compute instances |
| project\_id | Project where compute instance was created |
| region | Region where compute instance was created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
