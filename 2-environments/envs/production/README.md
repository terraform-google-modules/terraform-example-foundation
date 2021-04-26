<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associate this project with | `string` | n/a | yes |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| monitoring\_workspace\_users | Google Workspace or Cloud Identity group that have access to Monitoring Workspaces. | `string` | n/a | yes |
| org\_id | The organization id for the associated services | `string` | n/a | yes |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| project\_prefix | Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters. | `string` | `"prj"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| base\_shared\_vpc\_project\_id | Project for base shared VPC. |
| env\_folder | Environment folder created under parent. |
| env\_secrets\_project\_id | Project for environment related secrets. |
| monitoring\_project\_id | Project for monitoring infra. |
| restricted\_shared\_vpc\_project\_id | Project for restricted shared VPC. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


