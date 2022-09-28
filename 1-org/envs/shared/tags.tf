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
  tags = {
    environment = {
      shortname   = "environment${local.key_suffix}"
      description = "Environment identification"
      values      = ["bootstrap", "production", "non-production", "development"]
    }

    # Create your own Tags based on the following template.
    # For more details follow https://cloud.google.com/resource-manager/docs/tags/tags-creating-and-managing#creating
    # yourkeyname = {
    #   shortname   = "yourkeyname${local.key_suffix}"
    #   description = "Your Tag Key Description"
    #   values      = ["value_1", "value_2", ... , "value_x"]
    # }
  }

  tags_obj_list = flatten([
    for tag_key, tag_obj in local.tags : [
      for value in tag_obj.values : {
        shortkey = "${tag_key}"
        key      = "${tag_key}_${value}"
        val      = "${value}"
      }
    ]
  ])

  tags_output = { for k, v in google_tags_tag_value.tag_values : k => v.id }
  key_suffix  = var.create_unique_tag_key ? "-${random_string.tag_key_suffix.result}" : ""
}

resource "random_string" "tag_key_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "google_tags_tag_key" "tag_keys" {
  for_each = local.tags

  parent      = "organizations/${local.org_id}"
  short_name  = each.value.shortname
  description = each.value.description
}

resource "google_tags_tag_value" "tag_values" {
  for_each = { for v in local.tags_obj_list : v.key => v }

  parent     = "tagKeys/${google_tags_tag_key.tag_keys[each.value.shortkey].name}"
  short_name = each.value.val
}

resource "google_tags_tag_binding" "bind_folder_common" {
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.common.id}"
  tag_value = google_tags_tag_value.tag_values["environment_production"].id
}

resource "google_tags_tag_binding" "bind_folder_bootstrap" {
  parent    = "//cloudresourcemanager.googleapis.com/${local.bootstrap_folder_name}"
  tag_value = google_tags_tag_value.tag_values["environment_bootstrap"].id
}
