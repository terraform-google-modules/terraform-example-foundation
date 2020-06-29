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
  prefix = "${var.environment_code}_${local.vpc_type}_${local.vpc_label}"
}

module "access_context_manager_policy" {
  source      = "terraform-google-modules/vpc-service-controls/google"
  parent_id   = var.org_id
  policy_name = var.policy_name
}

module "access_level_members" {
  source      = "terraform-google-modules/vpc-service-controls/google//modules/access_level"
  description = "${local.prefix} Access Level"
  policy      = module.access_context_manager_policy.policy_id
  name        = "alp_${local.prefix}_members"
  members     = var.members
}

module "vpc_service_perimeter" {
  source         = "terraform-google-modules/vpc-service-controls/google//modules/regular_service_perimeter"
  policy         = module.access_context_manager_policy.policy_id
  perimeter_name = "sp_${local.prefix}_default_perimeter"
  description    = "Default VPC Service Controls perimeter"
  resources      = [var.project_number]

  restricted_services = var.restricted_services

  access_levels = [module.access_level_members.name]

  shared_resources = {
    all = [var.project_number]
  }
}
