<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| backend\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |
| business\_code | The code that describes which business unit owns the project | `string` | `"abcd"` | no |
| business\_unit | The business (ex. business\_unit\_1). | `string` | `"business_unit_1"` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| hostname | Hostname of instances | `string` | `"example-app"` | no |
| machine\_type | Machine type to create, e.g. n1-standard-1 | `string` | `"f1-micro"` | no |
| num\_instances | Number of instances to create | `number` | n/a | yes |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. Valid options are `sample-base` or `sample-restrict`. | `string` | n/a | yes |
| region | The GCP region to create and test resources in | `string` | `"us-central1"` | no |
| service\_account | Service account to attach to the instance. See https://www.terraform.io/docs/providers/google/r/compute_instance_template.html#service_account. | <pre>object({<br>    email  = string,<br>    scopes = set(string)<br>  })</pre> | `null` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| instances\_details | List of details for compute instances |
| instances\_self\_links | List of self-links for compute instances |
| project\_id | Project where compute instance was created |
| region | Region where compute instance was created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
