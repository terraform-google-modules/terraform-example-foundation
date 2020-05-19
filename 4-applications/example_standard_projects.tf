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

module "example_standard_projects" {
  source = "./modules/cloudbuild_project"

  impersonate_service_account = var.terraform_service_account
  org_id                      = var.org_id
  billing_account             = var.billing_account
  default_region              = var.default_region
  admin_group                 = "example_single_project_admin@YOURDOMAIN.COM"
  subnetwork_name             = "example-subnet"

  # Metadata
  project_prefix   = "sample-standard"
  cost_centre      = "cost-centre-1"
  application_name = "sample-standard-project-app"
}
