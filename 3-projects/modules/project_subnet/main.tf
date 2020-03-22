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
  subnet_data = [
    {
      subnet_name           = var.application_name
      subnet_ip             = var.ip_cidr_range
      subnet_region         = var.default_region
      subnet_private_access = var.enable_private_access
      subnet_flow_logs      = var.enable_vpc_flow_logs
      description           = var.application_name
    }
  ]
  subnet           = var.enable_networking == true ? local.subnet_data : []
  secondary_ranges = var.enable_networking == true ? var.secondary_ranges : []
  subnet_self_link = var.enable_networking == true ? [for subnet in module.project_subnet.subnets : replace(subnet.self_link, "https://www.googleapis.com/compute/v1/", "")] : []
}

/******************************************
  Project subnet
 *****************************************/

module "project_subnet" {
  source  = "terraform-google-modules/network/google//modules/subnets"
  version = "~> 2.1"

  project_id   = var.vpc_host_project_id
  network_name = var.vpc_self_link

  subnets = local.subnet

  secondary_ranges = {
    "${var.application_name}" = local.secondary_ranges
  }
}

/******************************************
  Subnet Restriction
 *****************************************/

resource "google_project_organization_policy" "restrict-subnetworks" {
  count      = var.enable_networking ? 1 : 0
  project    = var.project_id
  constraint = "compute.restrictSharedVpcSubnetworks"

  list_policy {
    allow {
      values = local.subnet_self_link
    }
  }
}