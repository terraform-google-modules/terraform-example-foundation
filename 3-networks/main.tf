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
  nonprod_host_project_id = data.google_projects.nonprod_host_project.projects[0].project_id
  prod_host_project_id    = data.google_projects.prod_host_project.projects[0].project_id
}


/******************************************
  VPC Host Projects
*****************************************/

data "google_projects" "nonprod_host_project" {
  filter = "labels.application_name=base-shared-vpc-host-nonprod"
}

data "google_projects" "prod_host_project" {
  filter = "labels.application_name=base-shared-vpc-host-prod"
}

/******************************************
 Shared VPCs
*****************************************/

module "shared_vpc_nonprod" {
  source               = "./modules/standard_shared_vpc"
  project_id           = local.nonprod_host_project_id
  environment_code     = "n"
  vpc_label            = "private"
  private_service_cidr = "10.0.80.0/20"
  nat_enabled          = true
  nat_bgp_asn_region1  = "64514"
  nat_bgp_asn_region2  = "64514"
  default_region1      = var.default_region1
  default_region2      = var.default_region2
  bgp_asn_subnet       = "64514"

  subnets = [
    {
      subnet_name           = "sb-n-shared-private-${var.default_region1}"
      subnet_ip             = "10.0.64.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Non prod example subnet"
    },
    {
      subnet_name           = "sb-n-shared-private-${var.default_region2}"
      subnet_ip             = "10.0.72.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Non prod example subnet"
    }
  ]
  secondary_ranges = {
    "sb-n-shared-private-${var.default_region1}" = [
      {
        range_name    = "rn-n-shared-private-${var.default_region1}-gke-pod"
        ip_cidr_range = "192.168.0.0/19"
      },
      {
        range_name    = "rn-n-shared-private-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.32.0/23"
      }
    ]
  }
}

module "shared_vpc_prod" {
  source               = "./modules/standard_shared_vpc"
  project_id           = local.prod_host_project_id
  environment_code     = "p"
  vpc_label            = "private"
  private_service_cidr = "10.0.16.0/20"
  nat_enabled          = true
  nat_bgp_asn_region1  = "64514"
  nat_bgp_asn_region2  = "64514"
  default_region1      = var.default_region1
  default_region2      = var.default_region2
  bgp_asn_subnet       = "64514"
  subnets = [
    {
      subnet_name           = "sb-p-shared-private-${var.default_region1}"
      subnet_ip             = "10.0.0.0/21"
      subnet_region         = var.default_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Prod example subnet"
    },
    {
      subnet_name           = "sb-p-shared-private-${var.default_region2}"
      subnet_ip             = "10.0.8.0/21"
      subnet_region         = var.default_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Prod example subnet"
    }
  ]
  secondary_ranges = {
    "sb-p-shared-private-${var.default_region1}" = [{
      range_name    = "rn-p-shared-private-${var.default_region1}-gke-pod"
      ip_cidr_range = "192.168.96.0/19"
      },
      {
        range_name    = "rn-p-shared-private-${var.default_region1}-gke-svc"
        ip_cidr_range = "192.168.128.0/23"
      }
    ]
  }
}
