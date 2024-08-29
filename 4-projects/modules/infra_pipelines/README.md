<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| billing\_account | The ID of the billing account to associated this project with. | `string` | n/a | yes |
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| cloud\_builder\_artifact\_repo | Artifact Registry (AR) repository that stores TF Cloud Builder images. | `string` | n/a | yes |
| cloudbuild\_project\_id | The project id where the pipelines and repos should be created. | `string` | n/a | yes |
| cloudbuildv2\_repository\_config | Configuration for integrating repositories with Cloud Build v2:<br>  - repo\_type: Specifies the type of repository. Supported types are 'GITHUBv2', 'GITLABv2', and 'CSR'.<br>  - repositories: A map of repositories to be created. The key must match the exact name of the repository. Each repository is defined by:<br>      - repository\_name: The name of the repository.<br>      - repository\_url: The HTTPS clone URL of the repository ending in `.git`.<br>  - github\_pat: (Optional) The personal access token for GitHub authentication.<br>  - github\_app\_id: (Optional) The application ID for a GitHub App used for authentication.<br>  - gitlab\_read\_authorizer\_credential: (Optional) The read authorizer credential for GitLab access.<br>  - gitlab\_authorizer\_credential: (Optional) The authorizer credential for GitLab access.<br><br>Note: If 'cloudbuildv2' is not configured, CSR (Cloud Source Repositories) will be used by default. | <pre>object({<br>    repo_type = string # Supported values are: GITHUBv2, GITLABv2 and CSR<br>    # repositories to be created, the key name must be exactly the same as the repository name<br>    repositories = map(object({<br>      repository_name = string,<br>      repository_url  = string,<br>    }))<br>    # Credential Config for each repository type<br>    github_pat                        = optional(string)<br>    github_app_id                     = optional(string)<br>    gitlab_read_authorizer_credential = optional(string)<br>    gitlab_authorizer_credential      = optional(string)<br>  })</pre> | <pre>{<br>  "repo_type": "CSR",<br>  "repositories": {}<br>}</pre> | no |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| private\_worker\_pool\_id | ID of the Cloud Build private worker pool. | `string` | n/a | yes |
| remote\_tfstate\_bucket | Bucket with remote state data to be used by the pipeline. | `string` | n/a | yes |
| terraform\_docker\_tag\_version | TAG version of the terraform docker image. | `string` | `"v1"` | no |
| vpc\_service\_control\_attach\_dry\_run | Whether the project will be attached to a VPC Service Control Perimeter with an explicit dry run spec flag, which may use different values for the dry run perimeter compared to the ENFORCED perimeter. | `bool` | `false` | no |
| vpc\_service\_control\_attach\_enabled | Whether the project will be attached to a VPC Service Control Perimeter in ENFORCED MODE. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers\_id | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| default\_region | Default region to create resources where applicable. |
| gar\_name | Artifact Registry (AR) repository name created to store runner images |
| log\_buckets | GCS Buckets to store Cloud Build logs |
| plan\_triggers\_id | CB plan triggers |
| repos | Created repos |
| state\_buckets | GCS Buckets to store TF state |
| terraform\_service\_accounts | App Infra Pipeline Terraform SA mapped to source repos as keys |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
