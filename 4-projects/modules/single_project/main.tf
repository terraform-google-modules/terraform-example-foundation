/**
 * Copyright 2021 Google LLC
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
  env_code        = element(split("", var.environment), 0)
  shared_vpc_mode = var.enable_hub_and_spoke ? "-spoke" : ""
}

module "project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 10.1"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = distinct(concat(var.activate_apis, ["billingbudgets.googleapis.com"]))
  name                        = "${var.project_prefix}-${var.business_code}-${local.env_code}-${var.project_suffix}"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.folder_id

  svpc_host_project_id = var.vpc_type == "" ? "" : data.google_compute_network.shared_vpc[0].project
  shared_vpc_subnets   = var.vpc_type == "" ? [] : data.google_compute_network.shared_vpc[0].subnetworks_self_links # Optional: To enable subnetting, replace to "module.networking_project.subnetwork_self_link"

  vpc_service_control_attach_enabled = var.vpc_service_control_attach_enabled
  vpc_service_control_perimeter_name = var.vpc_service_control_perimeter_name

  labels = {
    environment       = var.environment
    application_name  = var.application_name
    billing_code      = var.billing_code
    primary_contact   = element(split("@", var.primary_contact), 0)
    secondary_contact = element(split("@", var.secondary_contact), 0)
    business_code     = var.business_code
    env_code          = local.env_code
    vpc_type          = var.vpc_type
  }
  budget_alert_pubsub_topic   = var.alert_pubsub_topic
  budget_alert_spent_percents = var.alert_spent_percents
  budget_amount               = var.budget_amount
}

# Additional roles to project deployment SA created by project factory
resource "google_project_iam_member" "app_infra_pipeline_sa_roles" {
  for_each = toset(var.sa_roles)
  project  = module.project.project_id
  role     = each.value
  member   = "serviceAccount:${module.project.service_account_email}"
}

resource "google_folder_iam_member" "folder_browser" {
  count  = var.enable_cloudbuild_deploy ? 1 : 0
  folder = var.folder_id
  role   = "roles/browser"
  member = "serviceAccount:${module.project.service_account_email}"
}

resource "google_folder_iam_member" "folder_network_viewer" {
  count  = var.enable_cloudbuild_deploy ? 1 : 0
  folder = var.folder_id
  role   = "roles/compute.networkViewer"
  member = "serviceAccount:${module.project.service_account_email}"
}

# Allow Cloud Build SA to impersonate deployment SA
resource "google_service_account_iam_member" "cloudbuild_terraform_sa_impersonate_permissions" {
  count              = var.enable_cloudbuild_deploy ? 1 : 0
  service_account_id = module.project.service_account_name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${var.cloudbuild_sa}"
}
