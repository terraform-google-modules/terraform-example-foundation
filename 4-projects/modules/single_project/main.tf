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
  env_code = element(split("", var.environment), 0)
  source_repos = setintersection(
    toset(keys(var.app_infra_pipeline_service_accounts)),
    toset(keys(var.sa_roles))
  )
  pipeline_roles = var.enable_cloudbuild_deploy ? flatten([
    for repo in local.source_repos : [
      for role in var.sa_roles[repo] :
      {
        repo = repo
        role = role
        sa   = var.app_infra_pipeline_service_accounts[repo]
      }
    ]
  ]) : []

  network_user_role = var.enable_cloudbuild_deploy ? flatten([
    for repo in local.source_repos : [
      for subnet in var.shared_vpc_subnets :
      {
        repo   = repo
        subnet = element(split("/", subnet), index(split("/", subnet), "subnetworks", ) + 1, )
        region = element(split("/", subnet), index(split("/", subnet), "regions") + 1, )
        sa     = var.app_infra_pipeline_service_accounts[repo]
      }
    ]
  ]) : []
}

module "project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 15.0"

  random_project_id        = true
  random_project_id_length = 4
  activate_apis            = distinct(concat(var.activate_apis, ["billingbudgets.googleapis.com"]))
  name                     = "${var.project_prefix}-${local.env_code}-${var.business_code}-${var.project_suffix}"
  org_id                   = var.org_id
  billing_account          = var.billing_account
  folder_id                = var.folder_id

  svpc_host_project_id = var.shared_vpc_host_project_id
  shared_vpc_subnets   = var.shared_vpc_subnets # Optional: To enable subnetting, replace to "module.networking_project.subnetwork_self_link"

  vpc_service_control_attach_enabled = var.vpc_service_control_attach_enabled
  vpc_service_control_attach_dry_run = var.vpc_service_control_attach_dry_run
  vpc_service_control_perimeter_name = var.vpc_service_control_perimeter_name
  vpc_service_control_sleep_duration = var.vpc_service_control_sleep_duration

  labels = {
    environment       = var.environment
    application_name  = var.application_name
    billing_code      = var.billing_code
    primary_contact   = element(split("@", var.primary_contact), 0)
    secondary_contact = element(split("@", var.secondary_contact), 0)
    business_code     = var.business_code
    env_code          = local.env_code
    vpc               = var.vpc
  }
  budget_alert_pubsub_topic   = var.project_budget.alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.alert_spent_percents
  budget_amount               = var.project_budget.budget_amount
  budget_alert_spend_basis    = var.project_budget.alert_spend_basis
}

# Additional roles to the App Infra Pipeline service account
resource "google_project_iam_member" "app_infra_pipeline_sa_roles" {
  for_each = { for pr in local.pipeline_roles : "${pr.repo}-${pr.sa}-${pr.role}" => pr }

  project = module.project.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.sa}"
}

resource "google_folder_iam_member" "folder_network_viewer" {
  for_each = var.app_infra_pipeline_service_accounts

  folder = var.folder_id
  role   = "roles/compute.networkViewer"
  member = "serviceAccount:${each.value}"
}

resource "google_compute_subnetwork_iam_member" "service_account_role_to_vpc_subnets" {
  provider = google-beta
  for_each = { for nr in local.network_user_role : "${nr.repo}-${nr.subnet}-${nr.sa}" => nr }

  subnetwork = each.value.subnet
  role       = "roles/compute.networkUser"
  region     = each.value.region
  project    = var.shared_vpc_host_project_id
  member     = "serviceAccount:${each.value.sa}"
}
