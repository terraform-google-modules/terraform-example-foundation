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
  parent_resource_id   = local.parent_folder != "" ? local.parent_folder : local.org_id
  parent_resource_type = local.parent_folder != "" ? "folder" : "organization"
  parent_resources     = { resource = local.parent_resource_id }
  logs_filter          = <<EOF
    logName: /logs/cloudaudit.googleapis.com%2Factivity OR
    logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR
    logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR
    logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency OR
    logName: /logs/cloudaudit.googleapis.com%2Fpolicy OR
    logName: /logs/compute.googleapis.com%2Fvpc_flows OR
    logName: /logs/compute.googleapis.com%2Ffirewall OR
    logName: /logs/dns.googleapis.com%2Fdns_queries
EOF
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "logs_export" {
  source = "../../modules/centralized-logging"

  resources                      = local.parent_resources
  resource_type                  = local.parent_resource_type
  logging_destination_project_id = module.org_audit_logs.project_id
  billing_account                = local.billing_account
  enable_billing_account_sink    = true


  /******************************************
    Send logs to Storage
  *****************************************/
  storage_options = {
    logging_sink_filter          = local.logs_filter
    logging_sink_name            = "sk-c-logging-bkt"
    storage_bucket_name          = "bkt-${module.org_audit_logs.project_id}-org-logs-${random_string.suffix.result}"
    location                     = coalesce(var.log_export_storage_location, local.default_region)
    retention_policy_enabled     = var.log_export_storage_retention_policy != null
    retention_policy_is_locked   = var.log_export_storage_retention_policy == null ? null : var.log_export_storage_retention_policy.is_locked
    retention_policy_period_days = var.log_export_storage_retention_policy == null ? null : var.log_export_storage_retention_policy.retention_period_days
    force_destroy                = var.log_export_storage_force_destroy
    versioning                   = var.log_export_storage_versioning
  }

  /******************************************
    Send logs to Pub\Sub
  *****************************************/
  pubsub_options = {
    logging_sink_filter = local.logs_filter
    logging_sink_name   = "sk-c-logging-pub"
    topic_name          = "tp-org-logs-${random_string.suffix.result}"
    create_subscriber   = true
  }

  /******************************************
    Send logs to Logging project
  *****************************************/
  project_options = {
    logging_sink_name          = "sk-c-logging-prj"
    logging_sink_filter        = local.logs_filter
    log_bucket_id              = "AggregatedLogs"
    log_bucket_description     = "Project destination log bucket for aggregated logs"
    location                   = local.default_region
    linked_dataset_id          = "ds_c_prj_aggregated_logs_analytics"
    linked_dataset_description = "Project destination BigQuery Dataset for Logbucket analytics"
  }
}

/******************************************
  Billing logs (Export configured manually)
*****************************************/

resource "google_bigquery_dataset" "billing_dataset" {
  dataset_id    = "billing_data"
  project       = module.org_billing_export.project_id
  friendly_name = "GCP Billing Data"
  location      = coalesce(var.billing_export_dataset_location, local.default_region)
}
