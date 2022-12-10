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

#Groups creation resources

locals {
  optional_groups_to_create = {
    for key, value in var.groups.optional_groups : key => value
    if value != "" && var.groups.create_groups == true
  }
  required_groups_to_create = {
    for key, value in var.groups.required_groups : key => value
    if var.groups.create_groups == true
  }
}

data "google_organization" "org" {
  count        = var.groups.create_groups ? 1 : 0
  organization = var.org_id
}

module "required_group" {
  source   = "terraform-google-modules/group/google"
  version  = "~> 0.4"
  for_each = local.required_groups_to_create

  id                   = each.value
  display_name         = each.key
  description          = each.key
  initial_group_config = var.initial_group_config
  customer_id          = data.google_organization.org[0].directory_customer_id
}

module "optional_group" {
  source   = "terraform-google-modules/group/google"
  version  = "~> 0.4"
  for_each = local.optional_groups_to_create

  id                   = each.value
  display_name         = each.key
  description          = each.key
  initial_group_config = var.initial_group_config
  customer_id          = data.google_organization.org[0].directory_customer_id
}
