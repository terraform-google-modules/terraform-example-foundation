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

/******************************************
  Project Lookup
*******************************************/
data "google_projects" "network_projects_nonprod" {
  filter = "labels.application_name:org-shared-vpc-nonprod"
}

data "google_projects" "network_projects_prod" {
  filter = "labels.application_name:org-shared-vpc-prod"
}

data "google_projects" "application_projects_nonprod" {
  filter = "labels.application_name=${var.application_name} labels.environment=nonprod lifecycleState=ACTIVE"
}

data "google_projects" "application_projects_prod" {
  filter = "labels.application_name=${var.application_name} labels.environment=prod lifecycleState=ACTIVE"
}

data "google_project" "application_project" {
  for_each = toset(concat(local.application_filtered_projects_nonprod, local.application_filtered_projects_prod))

  project_id = each.value
}

/******************************************
  Folder Lookup
*******************************************/
data "google_folder" "application" {
  folder = "folders/${values(data.google_project.application_project)[0].folder_id}"
}

data "google_folder" "application_parent" {
  folder = data.google_folder.application.parent
}

data "google_active_folder" "util" {
  display_name = "util"
  parent       = data.google_folder.application_parent.name
}
