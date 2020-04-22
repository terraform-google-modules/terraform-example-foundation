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

resource "google_folder" "single_project_folder" {
  parent       = google_folder.app.id
  display_name = "single-project-app"
}

module "single_project_app" {
  source = "./modules/single_project"

  org_id                      = var.organization_id
  billing_account             = var.billing_account
  impersonate_service_account = var.terraform_service_account
  environment = "prod"

  folder_id = google_folder.single_project_folder.id

  # Metadata
  project_prefix   = "sample-single"
  cost_centre      = "cost-centre-1"
  application_name = "sample-single-project-app"
}
