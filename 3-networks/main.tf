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

/**************************
 Generic local variables
**************************/
locals {
  private_vpc_label = "private"
  cidrs = {
    prod = {
      base = {
        region1 = "10.0.0.0/21"
        private_service = "10.0.16.0/20"
      }
    }
    non-prod = {
      base = {
        region1 = "10.0.64.0/21"
        private_service = "10.0.80.0/20"
      }
    }
  }
}


/************************
 Nonprod local variables
*************************/
locals {
  nonprod_host_project_id  = "standard-shared-vpc-base" //data.google_projects.nonprod_host_project.projects[0].project_id
  nonprod_environment_code = "n"
}


/************************
 Prod local variables
*************************/
locals {
  prod_host_project_id  = "standard-shared-vpc-base" #data.google_projects.prod_host_project.projects[0].project_id  
  prod_environment_code = "p"
}

/******************************************
  VPC Host Projects
*****************************************/

# data "google_projects" "nonprod_host_project" {
#   filter = "labels.application_name=org-shared-vpc-nonprod"
# }

# data "google_projects" "prod_host_project" {
#   filter = "labels.application_name=org-shared-vpc-prod"
# }

/******************************************
 Shared VPCs
*****************************************/

module "shared_vpc_nonprod" {
  source           = "./modules/standard_shared_vpc"
  project_id       = local.nonprod_host_project_id
  environment_code = local.nonprod_environment_code
  vpc_label        = local.private_vpc_label
  default_region   = var.default_region
  private_service_cidr = local.cidrs.non-prod.base.private_service
  bgp_asn          = [64512]
  subnets = [
    {
      subnet_ip             = local.cidrs.non-prod.base.region1
      subnet_region         = var.default_region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Non prod example subnet."
      secondary_ranges = [
        {
          range_label   = "gke-pod"
          ip_cidr_range = "192.168.0.0/19"
        },
        {
          range_label   = "gke-svc"
          ip_cidr_range = "192.168.32.0/23"
        }
      ]
    }
  ]
}

module "shared_vpc_prod" {
  source           = "./modules/standard_shared_vpc"
  project_id       = local.prod_host_project_id
  environment_code = local.prod_environment_code
  vpc_label        = "${local.private_vpc_label}"
  default_region   = var.default_region
  private_service_cidr = local.cidrs.prod.base.private_service
  bgp_asn          = [64513]
  subnets = [
    {
      subnet_ip             = local.cidrs.prod.base.region1
      subnet_region         = var.default_region
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Prod example subnet."
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      secondary_ranges = [
        {
          range_label   = "gke-pod"
          ip_cidr_range = "192.168.96.0/19"
        },
        {
          range_label   = "gke-svc"
          ip_cidr_range = "192.168.128.0/23"
        }
      ]
    }
  ]
}
