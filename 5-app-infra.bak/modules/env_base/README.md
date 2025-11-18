<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| business\_unit | The business (ex. business\_unit\_1). | `string` | `"business_unit_1"` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| hostname | Hostname of instances | `string` | `"example-app"` | no |
| machine\_type | Machine type to create, e.g. n1-standard-1 | `string` | `"f1-micro"` | no |
| num\_instances | Number of instances to create | `number` | `1` | no |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. | `string` | n/a | yes |
| region | The GCP region to create and test resources in | `string` | `"us-central1"` | no |
| remote\_state\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| instances\_details | List of details for compute instances |
| instances\_self\_links | List of self-links for compute instances |
| project\_id | Project where compute instance was created |
| region | Region where compute instance was created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
