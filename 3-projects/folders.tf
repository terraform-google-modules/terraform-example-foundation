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
  Business Unit Folders
 *****************************************/
resource "google_folder" "example_business_unit" {
  display_name = "example-business-unit"
  parent       = var.dev_folder != "" ? "folders/${var.dev_folder}" : "organizations/${var.org_id}"
}

/******************************************
  Team Folders
 *****************************************/
module "example_team_folders" {
  source              = "./modules/folder_environments"
  parent_folder_id    = google_folder.example_business_unit.name
  folder_display_name = "example-team"
}
