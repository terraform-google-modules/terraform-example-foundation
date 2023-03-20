<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| monitoring\_workspace\_users | Google Workspace or Cloud Identity group that have access to Monitoring Workspaces. | `string` | n/a | yes |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| assured\_workload\_id | Assured Workload ID. |
| assured\_workload\_resources | Resources associated with the Assured Workload. |
| base\_shared\_vpc\_project\_id | Project for base shared VPC. |
| env\_folder | Environment folder created under parent. |
| env\_secrets\_project\_id | Project for environment related secrets. |
| monitoring\_project\_id | Project for monitoring infra. |
| restricted\_shared\_vpc\_project\_id | Project for restricted shared VPC. |
| restricted\_shared\_vpc\_project\_number | Project number for restricted shared VPC. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


