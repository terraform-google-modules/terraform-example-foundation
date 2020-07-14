<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The api to activate for the GCP project | list(string) | `<list>` | no |
| application\_name | The name of application where GCP resources relate | string | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| cost\_centre | The cost centre that links to the application | string | n/a | yes |
| environment | The environment the single project belongs to | string | n/a | yes |
| folder\_id | The folder id where project will be created | string | n/a | yes |
| impersonate\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| project\_prefix | The name of the GCP project | string | n/a | yes |
| skip\_gcloud\_download | Whether to skip downloading gcloud (assumes gcloud is already available outside the module) | bool | `"true"` | no |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
