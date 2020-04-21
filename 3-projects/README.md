# 3-projects

The purpose of this step is to setup folder structure, project, DNS and subnets used for applications.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-networks executed successfully.

## Usage
### Setup to run via Cloud Build
1. Clone repo gcloud source repos clone gcp-projects --project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Change freshly cloned repo and change to non master branch git checkout -b plan
1. Copy contents of foundation to new repo cp ../terraform-example-foundation/3-projects/* .
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Commit changes with git add . and git commit -m 'Your message'
1. Push your non master branch to trigger a plan git push --set-upstream origin plan
    1. Review the plan output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID
1. Merge changes to master with git checkout -b master and git push origin master
    1.Review the apply output in your cloud build project https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID


### Run terraform locally
1. Change into 3-projects folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Rename backend.tf.example backend.tf and update with your bucket from bootstrap.
1. Run terraform init
1. Run terraform plan and review output
1. Run terraform apply

### Subnetting Module (Optional)
This module enables users to allocate subnets with the project creation. The subnet can be used to host GCE or GKE in the application. To use this module, the following code needs to be uncommented.

#### *single_project/main.tf*
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
#### *single_project/variables.tf*
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

#### *standard_projects/main.tf*
```
/******************************************
  Project subnets (Optional)
 *****************************************/

module "networking_nonprod_project" {
  source = "../../modules/project_subnet"

  project_id          = module.nonprod_project.project_id
  enable_networking   = var.enable_networking
  application_name    = var.application_name
  vpc_host_project_id = local.nonprod_host_network.project
  vpc_self_link       = local.nonprod_host_network.self_link
  ip_cidr_range       = var.nonprod_subnet_ip_cidr_range
  secondary_ranges    = var.nonprod_subnet_secondary_ranges
}

module "networking_prod_project" {
  source = "../../modules/project_subnet"

  project_id          = module.prod_project.project_id
  enable_networking   = var.enable_networking
  application_name    = var.application_name
  vpc_host_project_id = local.prod_host_network.project
  vpc_self_link       = local.prod_host_network.self_link
  ip_cidr_range       = var.prod_subnet_ip_cidr_range
  secondary_ranges    = var.prod_subnet_secondary_ranges
}
```

#### standard_projects/variables.tf
```
/******************************************
  Project subnet (Optional)
 *****************************************/
variable "enable_networking" {
  description = "The flag to toggle the creation of subnets"
  type        = bool
  default     = true
}

variable "nonprod_subnet_ip_cidr_range" {
  description = "The CIDR Range of the subnet to get allocated to the nonprod project"
  type        = string
  default     = ""
}

variable "nonprod_subnet_secondary_ranges" {
  description = "The secondary CIDR Ranges of the subnet to get allocated to the nonprod project"
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}

variable "prod_subnet_ip_cidr_range" {
  description = "The CIDR Range of the subnet to get allocated to the prod project"
  type        = string
  default     = ""
}

variable "prod_subnet_secondary_ranges" {
  description = "The secondary CIDR Ranges of the subnet to get allocated to the prod project"
  type = list(object({
    range_name    = string
    ip_cidr_range = string
  }))
  default = []
}

```
### Private DNS Module (Optional)
This module provides the private DNS zone for the project created. The private DNS records can be resolved across all the projects in the same environment, i.e. nonprod and prod. To use this module, the following code needs to be uncommented.

#### *single_project/main.tf*
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
#### *single_project/variables.tf*
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

#### *standard_projects/main.tf*
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
#### *standard_projects/variables.tf*
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
#### *variables.tf*
```
/******************************************
  Private DNS Management (Optional)
 *****************************************/

variable "domain" {
   description = "The top level domain name for the organization"
   type        = string
}
```

#### *terraform.example.tf*
```
/******************************************
  Private DNS Management (Optional)
 *****************************************/

# domain = "example.com"
```

### Example Code for Subnetting and Private DNS (Optional)
If you have uncommented the Subnetting and Private DNS Management module from previous steps. Please also uncomment *single-project-example-optional.tf* and *standard-project-example-optional.tf* for the example code.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| billing\_account | The ID of the billing account to associated this project with | string | n/a | yes |
| default\_region | Default region for subnet. | string | n/a | yes |
| domain | The top level domain name for the organization | string | `""` | no |
| organization\_id | The organization id for the associated services | string | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
