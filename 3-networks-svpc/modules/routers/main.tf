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

module "routers" {
  source  = "terraform-google-modules/cloud-router/google"
  version = "~> 9.0"

  for_each = var.router_config.routers

  name       = "cr-${var.vpc_name}-${each.value.region}-${each.value.cr_suffix}"
  project_id = var.project_id
  region     = each.value.region
  network    = local.network_name

  bgp = {
    asn                  = var.router_config.bgp_asn
    advertised_groups    = var.router_config.advertised_groups
    advertised_ip_ranges = var.router_config.advertised_ip_ranges
  }

}
