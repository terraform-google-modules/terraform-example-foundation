<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| business\_unit | The business (ex. business\_unit\_1). | `string` | `"business_unit_1"` | no |
| confidential\_hostname | Hostname of confidential instance. | `string` | `"confidential-instance"` | no |
| confidential\_image\_digest | SHA256 digest of the Docker image to be used for running the workload in Confidential Space. This value ensures the integrity and immutability of the image, guaranteeing that only the expected and verified code is executed within the confidential environment. Expected format: `sha256:<digest>`. | `string` | n/a | yes |
| confidential\_instance\_type | (Optional) Defines the confidential computing technology the instance uses. SEV is an AMD feature. TDX is an Intel feature. One of the following values is required: SEV, SEV\_SNP, TDX. | `string` | `"SEV"` | no |
| confidential\_machine\_type | Machine type to create for confidential instance. | `string` | `"n2d-standard-2"` | no |
| cpu\_platform | The CPU platform used by this instance. If confidential\_instance\_type is set as SEV, then it is an AMD feature. TDX is an Intel feature. | `string` | `"AMD Milan"` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| num\_instances | Number of instances to create | `number` | `1` | no |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. | `string` | n/a | yes |
| region | The GCP region to create and test resources in | `string` | `"us-central1"` | no |
| remote\_state\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |
| source\_image\_family | Source image family used for confidential instance. The default is confidential-space. | `string` | `"confidential-space"` | no |
| source\_image\_project | Project where the source image comes from. The default project contains confidential-space-images images. See: https://cloud.google.com/confidential-computing/confidential-space/docs/confidential-space-images | `string` | `"confidential-space-images"` | no |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| confidential\_image\_digest | SHA256 digest of the Docker image. |
| confidential\_space\_project\_id | Project where confidential compute instance was created |
| confidential\_space\_project\_number | Project number from confidential compute instance |
| instances\_details | List of details for compute instances |
| instances\_self\_links | List of self-links for compute instances |
| project\_id | Project where compute instance was created |
| workload\_identity\_pool\_id | Workload identity pool ID. |
| workload\_pool\_provider\_id | Workload pool provider used by confidential space. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

