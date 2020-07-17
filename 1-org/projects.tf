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
  Projects for log sinks
*****************************************/

module "org_audit_logs" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 8.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = "prj-org-audit-logs"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.common.id
  skip_gcloud_download        = var.skip_gcloud_download
  activate_apis               = ["logging.googleapis.com", "bigquery.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "org-audit-logs"
  }
}

module "org_billing_logs" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 8.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = "prj-org-billing-logs"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.common.id
  skip_gcloud_download        = var.skip_gcloud_download
  activate_apis               = ["logging.googleapis.com", "bigquery.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "org-billing-logs"
  }
}

/******************************************
  Project for Org-wide Secrets
*****************************************/

module "org_secrets" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 8.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = "prj-org-secrets"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.common.id
  skip_gcloud_download        = var.skip_gcloud_download
  activate_apis               = ["logging.googleapis.com", "secretmanager.googleapis.com"]

  labels = {
    environment      = "prod"
    application_name = "org-secrets"
  }
}

/******************************************
  Project for Interconnect
*****************************************/

module "interconnect" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 8.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = "prj-interconnect"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.common.id
  skip_gcloud_download        = var.skip_gcloud_download

  labels = {
    environment      = "prod"
    application_name = "interconnect"
  }
}

/******************************************
  Project for SCC Notifications
*****************************************/

module "scc_notifications" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 8.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = "prj-scc-notifications"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.common.id
  activate_apis               = ["logging.googleapis.com", "pubsub.googleapis.com", "securitycenter.googleapis.com"]
  skip_gcloud_download        = var.skip_gcloud_download

  labels = {
    environment      = "prod"
    application_name = "scc-notification"
  }
}

/******************************************
  Project for DNS Hub
*****************************************/

module "dns_hub" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 8.0"
  random_project_id           = "true"
  impersonate_service_account = var.terraform_service_account
  default_service_account     = "depriviledge"
  name                        = "prj-dns-hub"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = google_folder.common.id
  skip_gcloud_download        = var.skip_gcloud_download

  activate_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "servicenetworking.googleapis.com",
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]

  labels = {
    environment      = "prod"
    application_name = "dns-hub"
  }
}
