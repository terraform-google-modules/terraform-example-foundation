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
  Audit Logs - Activity
*****************************************/

module "log_export_activity_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_activity_logs.destination_uri
  include_children       = true
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Factivity\""
  log_sink_name          = "bigquery_activity_logs"
  parent_resource_id     = var.dev_folder != "" ? var.dev_folder : var.org_id
  parent_resource_type   = var.dev_folder != "" ? "folder" : "organization"
  unique_writer_identity = true
}

module "bq_activity_logs" {
  source                      = "terraform-google-modules/log-export/google//modules/bigquery"
  version                     = "~> 4.0"
  project_id                  = module.org_audit_logs.project_id
  dataset_name                = "activity_logs"
  log_sink_writer_identity    = module.log_export_activity_logs.writer_identity
  default_table_expiration_ms = var.access_table_expiration_ms
}

/******************************************
  Audit Logs - System Event
*****************************************/

module "log_export_system_event_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_system_event_logs.destination_uri
  include_children       = true
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Fsystem_event\""
  log_sink_name          = "bigquery_system_event_logs"
  parent_resource_id     = var.dev_folder != "" ? var.dev_folder : var.org_id
  parent_resource_type   = var.dev_folder != "" ? "folder" : "organization"
  unique_writer_identity = true
}

module "bq_system_event_logs" {
  source                      = "terraform-google-modules/log-export/google//modules/bigquery"
  version                     = "~> 4.0"
  project_id                  = module.org_audit_logs.project_id
  dataset_name                = "system_event"
  log_sink_writer_identity    = module.log_export_system_event_logs.writer_identity
  location                    = var.default_region
  default_table_expiration_ms = var.system_event_table_expiration_ms
}

/******************************************
  Audit Logs - Data Access
*****************************************/

module "log_export_data_access_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_data_access_logs.destination_uri
  include_children       = true
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Fdata_access\""
  log_sink_name          = "bigquery_data_access_logs"
  parent_resource_id     = var.dev_folder != "" ? var.dev_folder : var.org_id
  parent_resource_type   = var.dev_folder != "" ? "folder" : "organization"
  unique_writer_identity = true
}

module "bq_data_access_logs" {
  source                      = "terraform-google-modules/log-export/google//modules/bigquery"
  version                     = "~> 4.0"
  project_id                  = module.org_audit_logs.project_id
  dataset_name                = "data_access"
  log_sink_writer_identity    = module.log_export_data_access_logs.writer_identity
  location                    = var.default_region
  default_table_expiration_ms = var.data_access_table_expiration_ms
}

/******************************************
  Audit Logs - IAM
*****************************************/

resource "google_project_iam_member" "audit_log_bq_user" {
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.user"
  member  = "group:${var.audit_data_users}"
}

resource "google_project_iam_member" "audit_log_bq_data_viewer" {
  project = module.org_audit_logs.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "group:${var.audit_data_users}"
}

/******************************************
  Billing logs (Export configured manually)
*****************************************/

resource "google_bigquery_dataset" "billing_dataset" {
  dataset_id    = "billing_data"
  project       = module.org_billing_logs.project_id
  friendly_name = "GCP Billing Data"
  location      = var.default_region
}

resource "google_project_iam_member" "billing_bq_user" {
  project = module.org_billing_logs.project_id
  role    = "roles/bigquery.user"
  member  = "group:${var.billing_data_users}"
}

resource "google_project_iam_member" "billing_bq_viewer" {
  project = module.org_billing_logs.project_id
  role    = "roles/bigquery.dataViewer"
  member  = "group:${var.billing_data_users}"
}

