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
  pipeline_roles = var.enable_cloudbuild_deploy ? flatten([
    for role in var.sa_roles : [
      for sa in var.app_infra_pipeline_service_accounts : {
        role = role
        sa   = sa
      }
    ]
  ]) : []
}

module "project" {
  source            = "terraform-google-modules/project-factory/google"
  version           = "~> 13.0"
  random_project_id = true
  activate_apis     = distinct(concat(var.activate_apis, ["billingbudgets.googleapis.com"]))
  name              = "${var.project_prefix}-${var.business_code}-${local.env_code}-${var.project_suffix}"
  org_id            = var.org_id
  billing_account   = var.billing_account
  folder_id         = var.folder_id

  svpc_host_project_id = var.shared_vpc_host_project_id
  shared_vpc_subnets   = var.shared_vpc_subnets # Optional: To enable subnetting, replace to "module.networking_project.subnetwork_self_link"

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

# Additional roles to the App Infra Pipeline service account
resource "google_project_iam_member" "app_infra_pipeline_sa_roles" {
  for_each = { for pr in local.pipeline_roles : "${pr.sa}-${pr.role}" => pr }

  project = module.project.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa}"
}

resource "google_folder_iam_member" "folder_network_viewer" {
  for_each = toset(var.app_infra_pipeline_service_accounts)

  folder = var.folder_id
  role   = "roles/compute.networkViewer"
  member = "serviceAccount:${each.value}"
}

resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = google-beta
  count    = length(var.shared_vpc_subnets)

  subnetwork = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(
      split("/", var.shared_vpc_subnets[count.index]),
      "subnetworks",
    ) + 1,
  )
  role = "roles/compute.networkUser"
  region = element(
    split("/", var.shared_vpc_subnets[count.index]),
    index(split("/", var.shared_vpc_subnets[count.index]), "regions") + 1,
  )
  project = var.shared_vpc_host_project_id
  member  = "serviceAccount:${var.app_infra_pipeline_service_accounts[0]}"
}
