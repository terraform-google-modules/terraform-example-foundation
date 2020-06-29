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
  environment_code          = "n"
  env                       = "nonprod"
  restricted_project_id     = data.google_projects.restricted_host_project.projects[0].project_id
  restricted_project_number = data.google_project.restricted_host_project.number
  region1_bgp_asn           = [64514, 64515]
  region2_bgp_asn           = [64516, 64517]
}

# TODO: Replace with label of the restricted shared vpc project
data "google_projects" "restricted_host_project" {
  filter = "labels.application_name=org-shared-vpc-${local.env}"
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
  nat_region           = var.nat_region
  private_service_cidr = "10.0.112.0/20"
  org_id               = var.org_id
  bgp_asn_nat          = "64512"
  subnets = [
    {
      subnet_ip             = "10.0.96.0/21"
      subnet_region         = var.subnet_region1
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      bgp_asn               = local.region1_bgp_asn
      description           = "First subnet example."
      secondary_ranges = [
        {
          range_label   = "gke-pod"
          ip_cidr_range = "192.168.0.0/19"
        },
        {
          range_label   = "gke-svc"
          ip_cidr_range = "192.168.32.0/23"
        },
      ]
      }, {
      subnet_ip             = "10.0.104.0/21"
      subnet_region         = var.subnet_region2
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
      bgp_asn               = local.region2_bgp_asn
      description           = "Second subnet example."
      secondary_ranges = [
        {
          range_label   = "gke-pod"
          ip_cidr_range = "192.168.64.0/19"
        },
        {
          range_label   = "gke-svc"
          ip_cidr_range = "192.168.128.0/23"
      }, ]
    }
  ]
}
