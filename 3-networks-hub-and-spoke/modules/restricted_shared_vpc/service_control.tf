/**
 * Copyright 2022 Google LLC
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
  prefix            = "${var.environment_code}_shared_restricted"
  access_level_name = "alp_${local.prefix}_members_${random_id.random_access_level_suffix.hex}"
  perimeter_name    = "sp_${local.prefix}_default_perimeter_${random_id.random_access_level_suffix.hex}"
  bridge_name       = "spb_c_to_${local.prefix}_bridge_${random_id.random_access_level_suffix.hex}"
}

resource "random_id" "random_access_level_suffix" {
  byte_length = 2
}

module "access_level_members" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "~> 4.0"

  description = "${local.prefix} Access Level"
  policy      = var.access_context_manager_policy_id
  name        = local.access_level_name
  members     = var.members
}

resource "time_sleep" "wait_vpc_sc_propagation" {
  create_duration  = "60s"
  destroy_duration = "60s"

  depends_on = [
    module.main,
    module.peering,
    google_compute_global_address.private_service_access_address,
    google_service_networking_connection.private_vpc_connection,
    module.region1_router1,
    module.region1_router2,
    module.region2_router1,
    module.region2_router2,
    module.private_service_connect,
    google_dns_policy.default_policy,
    module.peering_zone,
    google_compute_firewall.deny_all_egress,
    google_compute_firewall.allow_restricted_api_egress,
    google_compute_firewall.allow_all_egress,
    google_compute_firewall.allow_all_ingress,
    google_compute_router.nat_router_region1,
    google_compute_address.nat_external_addresses1,
    google_compute_router_nat.nat_external_addresses_region1,
    google_compute_router.nat_router_region2,
    google_compute_address.nat_external_addresses_region2,
    google_compute_router_nat.egress_nat_region2,
  ]
}

module "regular_service_perimeter" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  version = "~> 4.0"

  policy         = var.access_context_manager_policy_id
  perimeter_name = local.perimeter_name
  description    = "Default VPC Service Controls perimeter"
  resources      = [var.project_number]
  access_levels  = [module.access_level_members.name]

  restricted_services     = var.restricted_services
  vpc_accessible_services = ["RESTRICTED-SERVICES"]

  ingress_policies = var.ingress_policies
  egress_policies  = var.egress_policies

  depends_on = [
    time_sleep.wait_vpc_sc_propagation
  ]
}

resource "google_access_context_manager_service_perimeter" "bridge_to_network_hub_perimeter" {
  count = var.mode == "spoke" ? 1 : 0

  perimeter_type = "PERIMETER_TYPE_BRIDGE"
  parent         = "accessPolicies/${var.access_context_manager_policy_id}"
  name           = "accessPolicies/${var.access_context_manager_policy_id}/servicePerimeters/${local.bridge_name}"
  title          = local.bridge_name

  status {
    resources = formatlist("projects/%s", [var.project_number, var.restricted_net_hub_project_number])
  }

  depends_on = [module.regular_service_perimeter]
}
