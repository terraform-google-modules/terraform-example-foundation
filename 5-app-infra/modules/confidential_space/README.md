# Confidential Space Module

This module provisions Google Cloud [Confidential Space](https://cloud.google.com/confidential-computing/confidential-space/docs/confidential-space-overview) resources:
- Dedicated Workload Identity Pool (`confidential-space-pool`) and OIDC Attestation Verifier provider (`attestation-verifier`).
- Confidential VM instance template and compute instance running within a hardware-isolated Trusted Execution Environment (TEE) (AMD SEV/SNP or Intel TDX).
- Workload Identity User IAM binding for hardware attestation token exchange.

## Container Image & Local Deployment Architecture

Confidential Space requires a container image running inside the hardware-isolated enclave. The container image reference is injected into the instance metadata under the key `tee-image-reference`.

### 1. CI/CD Deployment Mode (Cloud Build, GitHub Actions, GitLab CI)
When using an automated CI/CD runner:
- The Artifact Registry project is automatically discovered via `data.terraform_remote_state.business_unit_shared.outputs.cicd_project_id`.
- The image reference defaults to:
  `${local.default_region}-docker.pkg.dev/${local.cicd_project_id}/${local.artifact_registry_repository}/confidential_space_image:latest`

### 2. Local Deployment Mode & Custom Workloads
When deploying locally with `./tf-wrapper.sh` or running a custom container image:
- In local mode (`build_type = local`), `cicd_project_id` is empty (`""`) because no automated CI/CD pipeline or pre-built runner image exists.
- You **must** provide `custom_tee_image_reference` pointing to your container image in Artifact Registry or Google Container Registry.
- You **must** also provide the corresponding `confidential_image_digest` (`sha256:<digest>`). Hardware attestation in the Workload Identity Pool provider validates this digest; if the digest does not match the image, the enclave fails attestation.

Example in `common.auto.tfvars`:
```hcl
custom_tee_image_reference = "us-central1-docker.pkg.dev/my-project/my-repo/my-app:latest"
confidential_image_digest  = "sha256:7b9d628c6e4e83a90327f2f76c024dcf50db6067160be1c1694f4c28f6eb07f4"
```

To extract the image digest:
```bash
gcloud artifacts docker images describe us-central1-docker.pkg.dev/my-project/my-repo/my-app:latest \
  --format="value(image_summary.digest)"
```

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
| custom\_tee\_image\_reference | Custom TEE container image reference to override the default image derived from cicd\_project\_id. | `string` | `""` | no |
| environment | The environment the single project belongs to | `string` | n/a | yes |
| num\_instances | Number of instances to create | `number` | `1` | no |
| project\_suffix | The name of the GCP project. Max 16 characters with 3 character business unit code. | `string` | n/a | yes |
| region | The GCP region to create and test resources in | `string` | `"us-central1"` | no |
| remote\_state\_bucket | Backend bucket to load remote state information from previous steps. | `string` | n/a | yes |
| source\_image\_family | Source image family used for confidential instance. The default is confidential-space. | `string` | `"confidential-space"` | no |
| source\_image\_project | Project where the source image comes from. The default project contains confidential-space-images images. See: https://cloud.google.com/confidential-computing/confidential-space/docs/confidential-space-images | `string` | `"confidential-space-images"` | no |
| universe\_domain | The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Cloud Dedicated (GCD). | `string` | `"googleapis.com"` | no |
| workload\_pool\_propagation\_sleep\_duration | The duration to wait for Workload Identity Pool propagation (e.g., 60s, 2m). | `string` | `"60s"` | no |

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
| tee\_image\_reference | Container image reference used for confidential space instance. |
| workload\_identity\_pool\_id | Workload identity pool ID. |
| workload\_pool\_provider\_id | Workload pool provider used by confidential space. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
