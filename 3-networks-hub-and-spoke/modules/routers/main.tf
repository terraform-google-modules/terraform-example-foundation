/**
 * Copyright 2026 Google LLC
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
  network_name = "vpc-${var.vpc_name}"
}

module "region1_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 9.0"

  name       = "cr-${var.vpc_name}-${var.region1}-cr5"
  project_id = var.project_id
  network    = local.network_name
  region     = var.region1
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = var.advertised_ip_ranges
  }
}

module "region1_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 9.0"

  name       = "cr-${var.vpc_name}-${var.region1}-cr6"
  project_id = var.project_id
  network    = local.network_name
  region     = var.region1
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = var.advertised_ip_ranges
  }
}

module "region2_router1" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 9.0"

  name       = "cr-${var.vpc_name}-${var.region2}-cr7"
  project_id = var.project_id
  network    = local.network_name
  region     = var.region2
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = var.advertised_ip_ranges
  }
}

module "region2_router2" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 9.0"

  name       = "cr-${var.vpc_name}-${var.region2}-cr8"
  project_id = var.project_id
  network    = local.network_name
  region     = var.region2
  bgp = {
    asn                  = var.bgp_asn_subnet
    advertised_groups    = ["ALL_SUBNETS"]
    advertised_ip_ranges = var.advertised_ip_ranges
  }
}
