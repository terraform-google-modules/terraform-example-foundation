<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| activate\_apis | The api to activate for the GCP project | list(string) | `<list>` | no |
| application\_name | The name of application where GCP resources relate | string | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| cost\_centre | The cost centre that links to the application | string | n/a | yes |
| impersonate\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |
| nonprod\_folder\_id | The folder id the non-production where project will be created | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| prod\_folder\_id | The folder id the production where the project will be created | string | n/a | yes |
| project\_prefix | The name of the GCP project | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| nonprod\_network\_name | The name of Shared VPC used by the project created for nonprod environment. |
| nonprod\_network\_project\_id | The network project where hosts the shared vpc used by the project created for nonprod environment. |
| nonprod\_project\_id | The project where application-related infrastructure will reside. |
| prod\_network\_name | The name of Shared VPC used by the project created for prod environment. |
| prod\_network\_project\_id | The network project where hosts the shared vpc used by the project created for prod environment. |
| prod\_project\_id | The project where application-related infrastructure will reside for prod environment. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
