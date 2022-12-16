<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_infra\_repos | A list of Cloud Source Repos to be created to hold app infra Terraform configs. | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with. | `string` | n/a | yes |
| bucket\_prefix | Name prefix to use for state bucket created. | `string` | `"bkt"` | no |
| cloud\_builder\_artifact\_repo | GAR Repo that stores TF Cloud Builder images. | `string` | n/a | yes |
| cloudbuild\_project\_id | The project id where the pipelines and repos should be created. | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| private\_worker\_pool\_id | ID of the Cloud Build private worker pool. | `string` | n/a | yes |
| remote\_tfstate\_bucket | Bucket with remote state data to be used by the pipeline. | `string` | n/a | yes |
| terraform\_docker\_tag\_version | TAG version of the terraform docker image. | `string` | `"v1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers\_id | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| default\_region | Default region to create resources where applicable. |
| gar\_name | GAR Repo name created to store runner images |
| log\_buckets | GCS Buckets to store Cloud Build logs |
| plan\_triggers\_id | CB plan triggers |
| repos | CSRs to store source code |
| state\_buckets | GCS Buckets to store TF state |
| terraform\_service\_accounts | App Infra Pipeline Terraform SA mapped to source repos as keys |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
