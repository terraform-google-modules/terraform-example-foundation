## Private DNS Module (Optional)
This module provides the private DNS zone for the project created. The private DNS records can be resolved across all the projects in the same environment, i.e. nonprod and prod. To use this module, the following code needs to be uncommented.

### *[single_project/main.tf](../single_project/main.tf)*
```
module "dns" {
  source = "../../modules/private_dns"

  project_id            = module.project.project_id
  enable_private_dns    = var.enable_private_dns
  application_name      = var.application_name
  environment           = var.environment
  top_level_domain      = var.domain
  shared_vpc_self_link  = local.host_network.self_link
  shared_vpc_project_id = local.host_network.project
}

```
### *[single_project/variables.tf](../single_project/variables.tf)*
```
/******************************************
  Project subnet (Optional)
 *****************************************/

variable "enable_private_dns" {
  type        = bool
  description = "The flag to create private dns zone in shared VPC"
  default     = true
}

variable "domain" {
  type        = string
  description = "The top level domain name for the organization"
}
```

### *[standard_projects/main.tf](../standard_projects/main.tf)*
```
/******************************************
  Project subnets (Optional)
 *****************************************/

module "dns_nonprod" {
  source = "../../modules/private_dns"

  project_id            = module.nonprod_project.project_id
  enable_private_dns    = var.enable_private_dns
  environment           = "nonprod"
  application_name      = var.application_name
  top_level_domain      = var.domain
  shared_vpc_self_link  = local.nonprod_host_network.self_link
  shared_vpc_project_id = local.nonprod_host_network.project
}

module "dns_prod" {
  source = "../../modules/private_dns"

  project_id            = module.prod_project.project_id
  enable_private_dns    = var.enable_private_dns
  environment           = "prod"
  application_name      = var.application_name
  top_level_domain      = var.domain
  shared_vpc_self_link  = local.prod_host_network.self_link
  shared_vpc_project_id = local.prod_host_network.project
}

```
### *[standard_projects/variables.tf](../standard_projects/variables.tf)*
```
variable "enable_private_dns" {
  type        = bool
  description = "The flag to create private dns zone in shared VPC"
  default     = true
}

variable "domain" {
  type        = string
  description = "The top level domain name for the organization"
  default     = ""
}

```
### *[variables.tf](../../variables.tf)*
```
/******************************************
  Private DNS Management (Optional)
 *****************************************/

variable "domain" {
   description = "The top level domain name for the organization"
   type        = string
}
```

### *[terraform.example.tf](../../terraform.example.tfvars)*
```
/******************************************
  Private DNS Management (Optional)
 *****************************************/

# domain = "example.com"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application\_name | Friendly application name to apply as a label. | string | n/a | yes |
| enable\_private\_dns | Flag to toggle the creation of dns zones | bool | `"true"` | no |
| environment | Environment to look up VPC and host project. | string | n/a | yes |
| project\_id | Project ID for VPC. | string | n/a | yes |
| shared\_vpc\_project\_id | Project ID for Shared VPC. | string | n/a | yes |
| shared\_vpc\_self\_link | Self link of Shared VPC Network. | string | n/a | yes |
| top\_level\_domain | The top level domain name for the organization | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
