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
  private_vpc_label = "private"

  nonprod_host_project_id       = data.google_projects.nonprod_host_project.projects[0].project_id
  nonprod_environment_code      = "n"
  nonprod_cidrs_sub_network1    = "10.0.64.0/21"
  nonprod_cidrs_sub_network2    = "10.0.72.0/21"
  nonprod_cidrs_private_service = "10.0.80.0/20"

  prod_host_project_id       = data.google_projects.prod_host_project.projects[0].project_id
  prod_environment_code      = "p"
  prod_cidrs_sub_network1    = "10.0.0.0/21"
  prod_cidrs_sub_network2    = "10.0.8.0/21"
  prod_cidrs_private_service = "10.0.16.0/20"
}


/******************************************
  VPC Host Projects
*****************************************/

data "google_projects" "nonprod_host_project" {
  filter = "labels.application_name=org-shared-vpc-nonprod"
}

data "google_projects" "prod_host_project" {
  filter = "labels.application_name=org-shared-vpc-prod"
}

/******************************************
 Shared VPCs
*****************************************/

module "shared_vpc_nonprod" {
  source               = "./modules/standard_shared_vpc"
  project_id           = local.nonprod_host_project_id
  environment_code     = local.nonprod_environment_code
  vpc_label            = local.private_vpc_label
  nat_region           = var.nat_region
  private_service_cidr = local.nonprod_cidrs_private_service
  bgp_asn_nat          = "64512"
  subnets = [
    {
      subnet_ip             = local.nonprod_cidrs_sub_network1
      subnet_region         = var.subnet_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      bgp_asn               = [64514, 64515]
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
    },
    {
      subnet_ip             = local.nonprod_cidrs_sub_network2
      subnet_region         = var.subnet_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      bgp_asn               = [64516, 64517]
      description           = "Non prod example subnet."
      secondary_ranges      = []
    }
  ]
}

module "shared_vpc_prod" {
  source               = "./modules/standard_shared_vpc"
  project_id           = local.prod_host_project_id
  environment_code     = local.prod_environment_code
  vpc_label            = local.private_vpc_label
  nat_region           = var.nat_region
  private_service_cidr = local.prod_cidrs_private_service
  bgp_asn_nat          = 64513
  subnets = [
    {
      subnet_ip             = local.prod_cidrs_sub_network1
      subnet_region         = var.subnet_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Prod example subnet."
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      bgp_asn               = [64518, 64519]
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
    },
    {
      subnet_ip             = local.prod_cidrs_sub_network2
      subnet_region         = var.subnet_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Prod example subnet."
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      bgp_asn               = [64520, 64521]
      secondary_ranges      = []
    }
  ]
}
