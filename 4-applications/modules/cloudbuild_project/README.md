<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| admin\_group | GSuite or Identity Group for GCP Application Administrators | string | n/a | yes |
| application\_name | Friendly application name to apply as a label. | string | n/a | yes |
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| cost\_centre | The cost centre that links to the application | string | n/a | yes |
| default\_region | Default region for subnet. | string | n/a | yes |
| impersonate\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |
| org\_id | The organization id for the associated services | string | n/a | yes |
| project\_prefix | The name of the GCP project | string | n/a | yes |
| subnetwork\_name | The name of the subnetwork the application infrastructure will use | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
