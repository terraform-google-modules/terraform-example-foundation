<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| folder\_deletion\_protection | Prevent Terraform from destroying or recreating the folder. | `string` | `true` | no |
| project\_deletion\_policy | The deletion policy for the project created. | `string` | `"PREVENT"` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| env\_folder | Environment folder created under parent. |
| env\_kms\_project\_id | Project for environment Cloud Key Management Service (KMS). |
| env\_kms\_project\_number | Project Number for environment Cloud Key Management Service (KMS). |
| env\_secrets\_project\_id | Project for environment related secrets. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
