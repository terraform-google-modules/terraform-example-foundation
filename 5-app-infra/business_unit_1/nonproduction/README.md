<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| confidential\_image\_digest | SHA256 digest of the Docker image to be used for running the workload in Confidential Space. This value ensures the integrity and immutability of the image, guaranteeing that only the expected and verified code is executed within the confidential environment. Expected format: `sha256:<digest>`. | `string` | `""` | no |
| instance\_region | The region where compute instance will be created. A subnetwork must exists in the instance region. | `string` | `null` | no |
| remote\_state\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| confidential\_available\_zones | List of available zones in region for confidential space. |
| confidential\_instances\_names | List of names for confidential compute instances |
| confidential\_instances\_zones | List of zone for confidential compute instances. |
| confidential\_space\_project\_id | Project where confidential compute instance was created |
| confidential\_space\_project\_number | Project number from confidential compute instance |
| instances\_details | List of details for compute instances |
| instances\_names | List of names for compute instances |
| instances\_self\_links | List of self-links for compute instances |
| instances\_zones | List of zone for compute instances |
| project\_id | Project where compute instance was created |
| region | Region where compute instance was created |
| workload\_identity\_pool\_id | Workload identity pool ID. |
| workload\_pool\_provider\_id | Workload pool provider used by confidential space. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
