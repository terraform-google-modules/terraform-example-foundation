<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| business\_unit | The business (ex. business\_unit\_1). | `string` | `"business_unit_1"` | no |
| confidential\_hostname | Hostname of confidential instance. | `string` | `"confidential-instance"` | no |
| confidential\_instance\_type | (Optional) Defines the confidential computing technology the instance uses. SEV is an AMD feature. TDX is an Intel feature. One of the following values is required: SEV, SEV\_SNP, TDX. | `string` | `"SEV"` | no |
| confidential\_machine\_type | Machine type to create for confidential instance. | `string` | `"n2d-standard-2"` | no |
| confidential\_space\_key\_name | Name to be used for KMS Key in confidential space. | `string` | `"workload-key"` | no |
| confidential\_space\_keyring\_name | Name to be used for KMS Keyring confidential space. | `string` | `"workload-key-ring"` | no |
| confidential\_space\_location\_kms | Case-Sensitive Location for KMS Keyring. | `string` | `"us"` | no |
| confidential\_space\_workload\_operator | The person who runs the workload that operates on the combined confidential data. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`. | `string` | `null` | no |
| cpu\_platform | The CPU platform used by this instance. If confidential\_instance\_type is set as SEV, then it is an AMD feature. TDX is an Intel feature. | `string` | `"AMD Milan"` | no |
| docker\_image\_reference | Docker image used by confidential space. | `string` | `null` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| gcs\_bucket\_prefix | Name prefix to be used for GCS Bucket | `string` | `"bkt"` | no |
| image\_digest | SHA256 digest of the Docker image. | `string` | n/a | yes |
| key\_rotation\_period | Rotation period in seconds to be used for KMS Key. | `string` | `"7776000s"` | no |
| location\_gcs | Case-Sensitive Location for GCS Bucket. | `string` | `"us"` | no |
| num\_instances | Number of instances to create | `number` | `1` | no |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. | `string` | n/a | yes |
| region | The GCP region to create and test resources in | `string` | `"us-central1"` | no |
| remote\_state\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |
| source\_image\_family | Source image family used for confidential instance. The default is confidential-space. | `string` | `"confidential-space"` | no |
| source\_image\_project | Project where the source image comes from. The default project contains confidential-space-images images. | `string` | `"confidential-space-images"` | no |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| image\_digest | SHA256 digest of the Docker image. |
| instances\_details | List of details for compute instances |
| instances\_self\_links | List of self-links for compute instances |
| project\_id | Project where compute instance was created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

