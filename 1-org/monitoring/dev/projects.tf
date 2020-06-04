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
  Initializing variables
*****************************************/

variable "billing_account" {}
variable "default_region" {}
variable "folder_id" {}
variable "monitoring_workspace_users" {}
variable "org_id" {}
variable "terraform_service_account" {}

/******************************************
  Projects for monitoring workspaces
*****************************************/

module "org_monitoring_dev" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  name                        = "org-monitoring-dev"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.folder_id
  activate_apis               = ["logging.googleapis.com", "monitoring.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "org-monitoring-dev"
  }
}

/******************************************
  Monitoring - IAM
*****************************************/

resource "google_project_iam_member" "monitoring_nonprod_editor" {
  project = module.org_monitoring_dev.project_id
  role    = "roles/monitoring.editor"
  member  = "group:${var.monitoring_workspace_users}"
}
