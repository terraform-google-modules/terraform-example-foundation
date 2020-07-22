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
  parent_resource_id   = var.parent_folder != "" ? var.parent_folder : var.org_id
  parent_resource_type = var.parent_folder != "" ? "folder" : "organization"
}

/******************************************
  Audit Logs - Activity
*****************************************/

module "log_export_activity_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_activity_logs.destination_uri
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Factivity\""
  log_sink_name          = "bigquery_activity_logs"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
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
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Fsystem_event\""
  log_sink_name          = "bigquery_system_event_logs"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
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

resource "google_organization_iam_audit_config" "organization_data_access_config" {
  count   = var.data_access_logs_enabled && var.parent_folder == "" ? 1 : 0
  org_id  = var.org_id
  service = "allServices"

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }

  audit_log_config {
    log_type = "ADMIN_READ"
  }
}

resource "google_folder_iam_audit_config" "folder_data_access_config" {
  count   = var.data_access_logs_enabled && var.parent_folder != "" ? 1 : 0
  folder  = "folders/${var.parent_folder}"
  service = "allServices"

  audit_log_config {
    log_type = "DATA_READ"
  }

  audit_log_config {
    log_type = "DATA_WRITE"
  }

  audit_log_config {
    log_type = "ADMIN_READ"
  }
}

module "log_export_data_access_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_data_access_logs.destination_uri
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Fdata_access\""
  log_sink_name          = "bigquery_data_access_logs"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
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
  VPC Flow Logs
*****************************************/

module "log_export_vpc_flow_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_vpc_flow_logs.destination_uri
  filter                 = "logName: \"/logs/compute.googleapis.com%2Fvpc_flows\""
  log_sink_name          = "bigquery_vpc_flow_logs"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
  unique_writer_identity = true
}

module "bq_vpc_flow_logs" {
  source                      = "terraform-google-modules/log-export/google//modules/bigquery"
  version                     = "~> 4.0"
  project_id                  = module.org_audit_logs.project_id
  dataset_name                = "vpc_flow"
  log_sink_writer_identity    = module.log_export_vpc_flow_logs.writer_identity
  location                    = var.default_region
  default_table_expiration_ms = var.vpc_flow_table_expiration_ms
}

/******************************************
  Firewall Rules Logging
*****************************************/

module "log_export_firewall_rules_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_firewall_rules_logs.destination_uri
  filter                 = "logName: \"/logs/compute.googleapis.com%2Ffirewall\""
  log_sink_name          = "bigquery_firewall_rules_logs"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
  unique_writer_identity = true
}

module "bq_firewall_rules_logs" {
  source                      = "terraform-google-modules/log-export/google//modules/bigquery"
  version                     = "~> 4.0"
  project_id                  = module.org_audit_logs.project_id
  dataset_name                = "firewall_rules"
  log_sink_writer_identity    = module.log_export_firewall_rules_logs.writer_identity
  location                    = var.default_region
  default_table_expiration_ms = var.firewall_rules_table_expiration_ms
}

/******************************************
  Access Transparency logs
*****************************************/

module "log_export_access_transparency_logs" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 4.0"
  destination_uri        = module.bq_access_transparency_logs.destination_uri
  filter                 = "logName: \"/logs/cloudaudit.googleapis.com%2Faccess_transparency\""
  log_sink_name          = "bigquery_access_transparency_logs"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
  unique_writer_identity = true
}

module "bq_access_transparency_logs" {
  source                      = "terraform-google-modules/log-export/google//modules/bigquery"
  version                     = "~> 4.0"
  project_id                  = module.org_audit_logs.project_id
  dataset_name                = "access_transparency"
  log_sink_writer_identity    = module.log_export_access_transparency_logs.writer_identity
  location                    = var.default_region
  default_table_expiration_ms = var.access_transparency_table_expiration_ms
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
