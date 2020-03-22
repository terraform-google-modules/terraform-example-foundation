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
  network_project_id = var.enable_networking ? data.google_projects.projects.projects[0].project_id : ""
}

module "project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  default_service_account     = "depriviledge"
  activate_apis               = var.activate_apis
  name                        = "${var.project_prefix}-${var.environment}"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.project_folder_map[var.environment]

  shared_vpc         = local.network_project_id
  shared_vpc_subnets = data.google_compute_network.shared_vpc.subnetworks_self_links

  labels = {
    environment      = var.environment
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}