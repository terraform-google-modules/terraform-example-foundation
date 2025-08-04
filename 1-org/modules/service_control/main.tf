/**
 * Copyright 2025 Google LLC
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
  prefix                    = "svpc"
  access_level_name         = "alp_${local.prefix}_members_${random_id.random_access_level_suffix.hex}"
  access_level_name_dry_run = "alp_${local.prefix}_members_dry_run_${random_id.random_access_level_suffix.hex}"
  perimeter_name            = "sp_${local.prefix}_default_common_perimeter_${random_id.random_access_level_suffix.hex}"
}

resource "random_id" "random_access_level_suffix" {
  byte_length = 2
}

module "access_level" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "~> 7.1.2"

  description = "${local.prefix} Access Level for use in an enforced perimeter"
  policy      = var.access_context_manager_policy_id
  name        = local.access_level_name
  members     = var.members
}

module "access_level_dry_run" {
  source  = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  version = "~> 7.1.2"

  description = "${local.prefix} Access Level for testing with a dry run perimeter"
  policy      = var.access_context_manager_policy_id
  name        = local.access_level_name_dry_run
  members     = var.members_dry_run
}

module "regular_service_perimeter" {
  source = "git::https://github.com/mariammartins/terraform-google-vpc-service-controls.git//modules/regular_service_perimeter?ref=fix-ingress-rules"
  # source  = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  # version = "~> 7.1.2"

  policy         = var.access_context_manager_policy_id
  perimeter_name = local.perimeter_name
  description    = "Default VPC Service Controls perimeter"

  # configurations for a perimeter in enforced mode.
  resources               = var.enforce_vpcsc ? var.resources : []
  resource_keys           = var.enforce_vpcsc ? var.resource_keys : []
  access_levels           = var.enforce_vpcsc ? [module.access_level.name] : []
  restricted_services     = var.enforce_vpcsc ? var.restricted_services : []
  vpc_accessible_services = var.enforce_vpcsc ? ["*"] : []
  ingress_policies        = var.enforce_vpcsc ? var.ingress_policies : []
  egress_policies         = var.enforce_vpcsc ? var.egress_policies : []

  # configurations for a perimeter in dry run mode.
  resources_dry_run               = var.resources_dry_run
  resource_keys_dry_run           = var.resource_keys_dry_run
  access_levels_dry_run           = [module.access_level_dry_run.name]
  restricted_services_dry_run     = var.restricted_services_dry_run
  vpc_accessible_services_dry_run = ["*"]
  ingress_policies_dry_run        = var.ingress_policies_dry_run
  egress_policies_dry_run         = var.egress_policies_dry_run
}

resource "time_sleep" "wait_vpc_sc_propagation" {
  create_duration = "60s"

  depends_on = [module.regular_service_perimeter]
}
