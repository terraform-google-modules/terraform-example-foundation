<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_infra\_repos | A list of Cloud Source Repos to be created to hold app infra Terraform configs | `list(string)` | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | `string` | n/a | yes |
| bucket\_region | Region to create GCS buckets for tfstate and Cloud Build artifacts | `string` | `"us-central1"` | no |
| cloudbuild\_apply\_filename | Path and name of Cloud Build YAML definition used for terraform apply. | `string` | `"cloudbuild-tf-apply.yaml"` | no |
| cloudbuild\_plan\_filename | Path and name of Cloud Build YAML definition used for terraform plan. | `string` | `"cloudbuild-tf-plan.yaml"` | no |
| cloudbuild\_project\_id | The project id where the pipelines and repos should be created | `string` | n/a | yes |
| default\_region | Default region to create resources where applicable. | `string` | n/a | yes |
| folder\_id | The ID of a folder to host this project | `string` | `""` | no |
| gar\_repo\_name | Custom name to use for GAR repo. | `string` | `""` | no |
| org\_id | GCP Organization ID | `string` | n/a | yes |
| project\_id | Custom project ID to use for project created. | `string` | `""` | no |
| project\_labels | Labels to apply to the project. | `map(string)` | `{}` | no |
| project\_prefix | Name prefix to use for projects created. | `string` | `"cft"` | no |
| terraform\_apply\_branches | List of git branches configured to run terraform apply Cloud Build trigger. All other branches will run plan by default. | `list(string)` | <pre>[<br>  "development",<br>  "non-production",<br>  "production"<br>]</pre> | no |
| terraform\_sa\_email | Email for terraform service account. | `string` | n/a | yes |
| terraform\_state\_bucket | Default state bucket, used in Cloud Build substitutions. | `string` | n/a | yes |
| terraform\_validator\_release | Default terraform-validator release. | `string` | `"2021-03-22"` | no |
| terraform\_version | Default terraform version. | `string` | `"0.13.6"` | no |
| terraform\_version\_sha256sum | sha256sum for default terraform version. | `string` | `"55f2db00b05675026be9c898bdd3e8230ff0c5c78dd12d743ca38032092abfc9"` | no |

## Outputs

| Name | Description |
|------|-------------|
| apply\_triggers | CB apply triggers |
| artifact\_buckets | GCS Buckets to store Cloud Build Artifacts |
| cloudbuild\_sa | Cloud Build service account |
| plan\_triggers | CB plan triggers |
| repos | CSRs to store source code |
| state\_buckets | GCS Buckets to store TF state |
| tf\_runner\_artifact\_repo | GAR Repo created to store runner images |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
