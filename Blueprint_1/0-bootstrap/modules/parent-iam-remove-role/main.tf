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
  org_id     = var.parent_type == "organization" ? var.parent_id : ""
  folder_id  = var.parent_type == "folder" ? var.parent_id : ""
  project_id = var.parent_type == "project" ? var.parent_id : ""
}

resource "google_organization_iam_binding" "iam_remove" {
  for_each = toset(var.parent_type == "organization" ? var.roles : [])

  org_id  = local.org_id
  role    = each.key
  members = []
}

resource "google_folder_iam_binding" "iam_remove" {
  for_each = toset(var.parent_type == "folder" ? var.roles : [])

  folder  = local.folder_id
  role    = each.key
  members = []
}

resource "google_project_iam_binding" "iam_remove" {
  for_each = toset(var.parent_type == "project" ? var.roles : [])

  project = local.project_id
  role    = each.key
  members = []
}
