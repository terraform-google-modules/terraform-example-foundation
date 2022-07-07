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

module "required_group" {
  for_each = tomap(var.create_groups_holder.required_groups)
  source   = "terraform-google-modules/group/google"
  version  = "~> 0.1"

  id                   = each.value
  display_name         = each.key
  description          = each.key
  initial_group_config = var.initial_group_config
  customer_id          = var.customer_id
}

module "optional_group" {
  for_each = var.create_groups_holder.optional_groups != null ? tomap(var.create_groups_holder.optional_groups) : {}
  source   = "terraform-google-modules/group/google"
  version  = "~> 0.1"

  id                   = each.value
  display_name         = each.key
  description          = each.key
  initial_group_config = var.initial_group_config
  customer_id          = var.customer_id
}
