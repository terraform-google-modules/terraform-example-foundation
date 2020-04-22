### Subnetting Module (Optional)
This module enables users to allocate subnets with the project creation. The subnet can be used to host GCE or GKE in the application. To use this module, the following code needs to be uncommented.

#### *[single_project/main.tf](../standard_projects/main.tf)*
```
/******************************************
  Project subnets (Optional)
 *****************************************/

module "networking_project" {
  source = "../../modules/project_subnet"

  project_id       = module.project.project_id
  application_name = var.application_name

  enable_networking   = var.enable_networking
  vpc_host_project_id = local.host_network.project
  vpc_self_link       = local.host_network.self_link
  ip_cidr_range       = var.subnet_ip_cidr_range
  secondary_ranges    = var.subnet_secondary_ranges
}
```
#### *[single_project/variables.tf](../single_project/variables.tf)*
```
/******************************************
  Project subnet (Optional)
 *****************************************/

variable "enable_networking" {
  description = "The flag to create subnets in shared VPC"
  type        = bool
  default     = true
}

variable "subnet_ip_cidr_range" {
  description = "The CIDR Range of the subnet to get allocated to the project"
  type        = string
  default     = ""
}

variable "subnet_secondary_ranges" {
  description = "The secondary CIDR Ranges of the subnet to get allocated to the project"
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}
```
#### *[single_project/main.tf](../single_project/main.tf#L21)*
To replace the value in the comment for *shared_vpc_subnets* property.

```
module "project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-${var.environment}"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.folder_id

  shared_vpc         = local.host_network.project
  shared_vpc_subnets = local.host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_project.subnetwork_self_link"

  labels = {
    environment      = var.environment
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

```

#### *[standard_projects/main.tf](../standard_projects/main.tf#L37)*
To replace the value in the comment for *shared_vpc_subnets* property.

```
module "nonprod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-nonprod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.nonprod_folder_id

  shared_vpc         = local.nonprod_host_network.project
  shared_vpc_subnets = local.nonprod_host_network.subnetworks_self_links  # Optional: To enable subnetting, to replace to "module.networking_nonprod_project.subnetwork_self_link"

  labels = {
    environment      = "nonprod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

module "prod_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-prod"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.prod_folder_id

  shared_vpc         = local.prod_host_network.project
  shared_vpc_subnets = local.prod_host_network.subnetworks_self_links # Optional: To enable subnetting, to replace to "module.networking_prod_project.subnetwork_self_link"

  labels = {
    environment      = "prod"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| application\_name | Name for subnets | string | n/a | yes |
| default\_region | Default region for resources. | string | n/a | yes |
| enable\_networking | The Flag to toggle the creation of subnets | bool | `"true"` | no |
| enable\_private\_access | Flag to enable Google Private access in the subnet. | bool | `"true"` | no |
| enable\_vpc\_flow\_logs | Flag to enable VPC flow logs with default configuration. | bool | `"false"` | no |
| ip\_cidr\_range | CIDR Block to use for the subnet. | string | n/a | yes |
| project\_id | Project Id | string | n/a | yes |
| secondary\_ranges | Secondary ranges that will be used in some of the subnets | object | `<list>` | no |
| vpc\_host\_project\_id | VPC Host project ID. | string | n/a | yes |
| vpc\_self\_link | Self link for VPC to create the subnet in. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| subnetwork\_self\_link | The self-link of subnet being create |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
