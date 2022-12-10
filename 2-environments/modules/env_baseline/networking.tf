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

/******************************************
  Projects for Shared VPCs
*****************************************/

module "base_shared_vpc_host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id           = true
  random_project_id_length    = 4
  name                        = format("%s-%s-shared-base", local.project_prefix, var.environment_code)
  org_id                      = local.org_id
  billing_account             = local.billing_account
  folder_id                   = google_folder.env.id
  disable_services_on_destroy = false
  depends_on                  = [time_sleep.wait_60_seconds]
  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  labels = {
    environment       = var.env
    application_name  = "base-shared-vpc-host"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = var.environment_code
  }
  budget_alert_pubsub_topic   = var.project_budget.base_network_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.base_network_alert_spent_percents
  budget_amount               = var.project_budget.base_network_budget_amount
}

module "restricted_shared_vpc_host_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id           = true
  random_project_id_length    = 4
  name                        = format("%s-%s-shared-restricted", local.project_prefix, var.environment_code)
  org_id                      = local.org_id
  billing_account             = local.billing_account
  folder_id                   = google_folder.env.id
  disable_services_on_destroy = false
  depends_on                  = [time_sleep.wait_60_seconds]
  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "container.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  labels = {
    environment       = var.env
    application_name  = "restricted-shared-vpc-host"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = var.environment_code
  }
  budget_alert_pubsub_topic   = var.project_budget.restricted_network_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.restricted_network_alert_spent_percents
  budget_amount               = var.project_budget.restricted_network_budget_amount
}
