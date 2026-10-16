<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| confidential\_image\_digest | SHA256 digest of the Docker image to be used for running the workload in Confidential Space. This value ensures the integrity and immutability of the image, guaranteeing that only the expected and verified code is executed within the confidential environment. Expected format: `sha256:<digest>`. | `string` | `""` | no |
| confidential\_instance\_zone | Zone where the confidential compute instance should be created (e.g. us-central1-b, us-central1-c). If null, defaults to us-central1-b. | `string` | `null` | no |
| custom\_tee\_image\_reference | Custom TEE container image reference to override the default image derived from cicd\_project\_id. | `string` | `""` | no |
| disk\_type | Boot disk type, can be either pd-ssd, local-ssd, pd-standard, or hyperdisk-balanced(Air Gapped) | `string` | `"pd-standard"` | no |
| instance\_region | The region where compute instance will be created. A subnetwork must exists in the instance region. | `string` | `null` | no |
| machine\_type | Machine type to create, e.g. n1-standard-1 | `string` | `"f1-micro"` | no |
| remote\_state\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |
| source\_image | Source disk image. if not provided defaults to the latest public Rocky Linux 9 optimized for GCP image. | `string` | `""` | no |
| universe\_domain | The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Cloud Dedicated (GCD). | `string` | `"googleapis.com"` | no |
| workload\_pool\_propagation\_sleep\_duration | The duration to wait for Workload Identity Pool propagation (e.g., 60s, 2m). | `string` | `"60s"` | no |

## Outputs

| Name | Description |
|------|-------------|
| available\_zones | List of available zones in region |
| confidential\_available\_zones | List of available zones in region for confidential space. |
| confidential\_instances\_names | List of names for confidential compute instances. |
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
