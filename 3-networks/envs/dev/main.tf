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
}

data "google_projects" "restricted_host_project" {
  filter = "labels.application_name=restricted-shared-vpc-host-${local.env}"
}

data "google_project" "restricted_host_project" {
  project_id = data.google_projects.restricted_host_project.projects[0].project_id
}

/******************************************
 Restricted shared VPC
*****************************************/
module "restricted_shared_vpc" {
  source               = "../../modules/restricted_shared_vpc"
  project_id           = local.restricted_project_id
  project_number       = local.restricted_project_number
  environment_code     = local.environment_code
  policy_name          = "${local.environment_code}-restricted-access-policy"
  restricted_services  = ["bigquery.googleapis.com", "storage.googleapis.com"]
  members              = ["serviceAccount:${var.terraform_service_account}"]
  private_service_cidr = "10.0.176.0/20"
  org_id               = var.org_id
  nat_enabled          = false
  bgp_asn_subnet       = "64514"

  subnets = [
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.subnet_region1}"
      subnet_ip             = "10.0.160.0/21"
      subnet_region         = var.subnet_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "First ${local.env} subnet example."
    },
    {
      subnet_name           = "sb-${local.environment_code}-shared-restricted-${var.subnet_region2}"
      subnet_ip             = "10.0.168.0/21"
      subnet_region         = var.subnet_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      description           = "Second ${local.env} subnet example."
    }
  ]
  secondary_ranges = {
    "sb-${local.environment_code}-shared-restricted-${var.subnet_region1}" = [
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.subnet_region1}-gke-pod"
        ip_cidr_range = "192.168.0.0/19"
      },
      {
        range_name    = "rn-${local.environment_code}-shared-restricted-${var.subnet_region1}-gke-svc"
        ip_cidr_range = "192.168.32.0/23"
      }
    ]
  }
}
