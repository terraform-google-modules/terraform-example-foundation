/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

locals {
  environment_code          = "d"
  env                       = "dev"
  restricted_project_id     = data.google_projects.restricted_host_project.projects[0].project_id
  restricted_project_number = data.google_project.restricted_host_project.number
  private_project_id        = data.google_projects.private_project.projects[0].project_id
}

/******************************************
  VPC Host Projects
*****************************************/

data "google_projects" "restricted_host_project" {
  filter = "labels.application_name=restricted-shared-vpc-host-${local.env}"
}

data "google_project" "restricted_host_project" {
  project_id = data.google_projects.restricted_host_project.projects[0].project_id
}

data "google_projects" "private_project" {
  filter = "labels.application_name=base-shared-vpc-host-${local.env}"
}

/******************************************
 Restricted shared VPC
*****************************************/
module "restricted_shared_vpc" {
  source                           = "../../modules/restricted_shared_vpc"
  project_id                       = local.restricted_project_id
  project_number                   = local.restricted_project_number
  environment_code                 = local.environment_code
  access_context_manager_policy_id = var.access_context_manager_policy_id
  restricted_services              = ["bigquery.googleapis.com", "storage.googleapis.com"]
  members                          = ["serviceAccount:${var.terraform_service_account}"]
  private_service_cidr             = "10.0.176.0/20"
  org_id                           = var.org_id
  nat_enabled                      = false
  bgp_asn_subnet                   = "64514"
  default_region1                  = var.default_region1
  default_region2                  = var.default_region2
  domain                           = var.domain

  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region1}"
      subnet_ip             = "10.0.160.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.default_region2}"
      subnet_ip             = "10.0.168.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-restricted-${var.default_region1}" = [
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-pod"
        ip_cidr_range = "192.168.0.0/19"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.32.0/23"
      }
    ]
  }
}

/******************************************
 Interconnect for restricted shared VPC
*****************************************/
# uncommnet if you have done the requirement steps listed in ../../modules/dedicated_interconnect/README.md
# update the interconnect, interconnect locations, and peer field with actual values.

# module "shared_restricted_interconnect" {
#   source = "../../modules/dedicated_interconnect"

#   vpc_name = "${local.environment_code}-shared-restricted"

#   region1                        = var.default_region1
#   region1_router1_name           = module.restricted_shared_vpc.region1_router1.router.name
#   region1_interconnect1          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-1"
#   region1_interconnect1_location = "las-zone1-770"
#   region1_router2_name           = module.restricted_shared_vpc.region1_router2.router.name
#   region1_interconnect2          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-2"
#   region1_interconnect2_location = "las-zone1-770"

#   region2                        = var.default_region2
#   region2_router1_name           = module.restricted_shared_vpc.region2_router1.router.name
#   region2_interconnect1          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-3"
#   region2_interconnect1_location = "lax-zone2-19"
#   region2_router2_name           = module.restricted_shared_vpc.region2_router2.router.name
#   region2_interconnect2          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-4"
#   region2_interconnect2_location = "lax-zone1-403"

#   peer_asn        = "64515"
#   peer_ip_address = "8.8.8.8" # on-prem router ip address
#   peer_name       = "interconnect-peer"
# }

/******************************************
 Base shared VPC
*****************************************/

module "private_shared_vpc" {
  source                     = "../../modules/standard_shared_vpc"
  project_id                 = local.private_project_id
  environment_code           = local.environment_code
  vpc_label                  = "private"
  private_service_cidr       = "10.0.144.0/20"
  nat_enabled                = true
  nat_bgp_asn                = "64514"
  default_region1            = var.default_region1
  default_region2            = var.default_region2
  domain                     = var.domain
  bgp_asn_subnet             = "64514"
  windows_activation_enabled = true
  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-private-${var.default_region1}"
      subnet_ip             = "10.0.128.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-private-${var.default_region2}"
      subnet_ip             = "10.0.136.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-private-${var.default_region1}" = [{
      range_name    = "rn-${local.environment_code}-shared-private-${var.default_region1}-gke-pod"
      ip_cidr_range = "192.168.96.0/19"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-private-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.128.0/23"
      }
    ]
  }
}

/******************************************
 Interconnect for base shared VPC
*****************************************/

# uncommnet if you have done the requirement steps listed in ../../modules/dedicated_interconnect/README.md
# update the interconnect, interconnect locations, and peer field with actual values.

# module "shared_base_interconnect" {
#   source = "../../modules/dedicated_interconnect"

#   vpc_name = "${local.environment_code}-shared-private"

#   region1                        = var.default_region1
#   region1_router1_name           = module.private_shared_vpc.region1_router1.router.name
#   region1_interconnect1          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-1"
#   region1_interconnect1_location = "las-zone1-770"
#   region1_router2_name           = module.private_shared_vpc.region1_router2.router.name
#   region1_interconnect2          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-2"
#   region1_interconnect2_location = "las-zone1-770"

#   region2                        = var.default_region2
#   region2_router1_name           = module.private_shared_vpc.region2_router1.router.name
#   region2_interconnect1          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-3"
#   region2_interconnect1_location = "lax-zone2-19"
#   region2_router2_name           = module.private_shared_vpc.region2_router2.router.name
#   region2_interconnect2          = "https://www.googleapis.com/compute/v1/projects/example-interconnect-project/global/interconnects/example-interconnect-4"
#   region2_interconnect2_location = "lax-zone1-403"

#   peer_asn        = "64515"
#   peer_ip_address = "8.8.8.8" # on-prem router ip address
#   peer_name       = "interconnect-peer"
# }
