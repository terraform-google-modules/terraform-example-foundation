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
  hub_and_spoke_roles = [
    "roles/compute.instanceAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/resourcemanager.projectIamAdmin",
    "roles/iam.serviceAccountUser",
  ]
}

/******************************************
  Projects for log sinks
*****************************************/

module "org_audit_logs" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-logging"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id
  activate_apis            = ["logging.googleapis.com", "bigquery.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-logging"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.org_audit_logs_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.org_audit_logs_alert_spent_percents
  budget_amount               = var.project_budget.org_audit_logs_budget_amount
}

module "org_billing_logs" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-billing-logs"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id
  activate_apis            = ["logging.googleapis.com", "bigquery.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-billing-logs"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.org_billing_logs_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.org_billing_logs_alert_spent_percents
  budget_amount               = var.project_budget.org_billing_logs_budget_amount
}

/******************************************
  Project for Org-wide Secrets
*****************************************/

module "org_secrets" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-secrets"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id
  activate_apis            = ["logging.googleapis.com", "secretmanager.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-secrets"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.org_secrets_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.org_secrets_alert_spent_percents
  budget_amount               = var.project_budget.org_secrets_budget_amount
}

/******************************************
  Project for Interconnect
*****************************************/

module "interconnect" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-interconnect"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id
  activate_apis            = ["billingbudgets.googleapis.com", "compute.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-interconnect"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.interconnect_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.interconnect_alert_spent_percents
  budget_amount               = var.project_budget.interconnect_budget_amount
}

/******************************************
  Project for SCC Notifications
*****************************************/

module "scc_notifications" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-scc"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id
  activate_apis            = ["logging.googleapis.com", "pubsub.googleapis.com", "securitycenter.googleapis.com", "billingbudgets.googleapis.com"]

  labels = {
    environment       = "production"
    application_name  = "org-scc"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.scc_notifications_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.scc_notifications_alert_spent_percents
  budget_amount               = var.project_budget.scc_notifications_budget_amount
}

/******************************************
  Project for DNS Hub
*****************************************/

module "dns_hub" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-dns-hub"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  labels = {
    environment       = "production"
    application_name  = "org-dns-hub"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.dns_hub_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.dns_hub_alert_spent_percents
  budget_amount               = var.project_budget.dns_hub_budget_amount
}

/******************************************
  Project for Base Network Hub
*****************************************/

module "base_network_hub" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"
  count   = var.enable_hub_and_spoke ? 1 : 0

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-base-net-hub"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  labels = {
    environment       = "production"
    application_name  = "org-base-net-hub"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.base_net_hub_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.base_net_hub_alert_spent_percents
  budget_amount               = var.project_budget.base_net_hub_budget_amount
}

resource "google_project_iam_member" "network_sa_base" {
  for_each = toset(var.enable_hub_and_spoke ? local.hub_and_spoke_roles : [])

  project = module.base_network_hub[0].project_id
  role    = each.key
  member  = "serviceAccount:${local.networks_step_terraform_service_account_email}"
}

/******************************************
  Project for Restricted Network Hub
*****************************************/

module "restricted_network_hub" {
  source  = "terraform-google-modules/project-factory/google"
  version = "~> 14.0"
  count   = var.enable_hub_and_spoke ? 1 : 0

  random_project_id        = true
  random_project_id_length = 4
  default_service_account  = "deprivilege"
  name                     = "${local.project_prefix}-c-restricted-net-hub"
  org_id                   = local.org_id
  billing_account          = local.billing_account
  folder_id                = google_folder.common.id

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "billingbudgets.googleapis.com"
  ]

  labels = {
    environment       = "production"
    application_name  = "org-restricted-net-hub"
    billing_code      = "1234"
    primary_contact   = "example1"
    secondary_contact = "example2"
    business_code     = "abcd"
    env_code          = "p"
  }
  budget_alert_pubsub_topic   = var.project_budget.restricted_net_hub_alert_pubsub_topic
  budget_alert_spent_percents = var.project_budget.restricted_net_hub_alert_spent_percents
  budget_amount               = var.project_budget.restricted_net_hub_budget_amount
}

resource "google_project_iam_member" "network_sa_restricted" {
  for_each = toset(var.enable_hub_and_spoke ? local.hub_and_spoke_roles : [])

  project = module.restricted_network_hub[0].project_id
  role    = each.key
  member  = "serviceAccount:${local.networks_step_terraform_service_account_email}"
}
