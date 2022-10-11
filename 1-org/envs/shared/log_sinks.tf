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
  main_logs_filter     = <<EOF
    logName: /logs/cloudaudit.googleapis.com%2Factivity OR
    logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR
    logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR
    logName: /logs/compute.googleapis.com%2Fvpc_flows OR
    logName: /logs/compute.googleapis.com%2Ffirewall OR
    logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency
EOF
  all_logs_filter      = ""
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

  /******************************************
    Send logs to BigQuery
  *****************************************/
  bigquery_options = {
    logging_sink_name          = "sk-c-logging-bq"
    logging_sink_filter        = local.main_logs_filter
    dataset_name               = "audit_logs"
    expiration_days            = var.audit_logs_table_expiration_days
    delete_contents_on_destroy = var.audit_logs_table_delete_contents_on_destroy
  }

  /******************************************
    Send logs to Storage
  *****************************************/
  storage_options = {
    logging_sink_filter          = local.all_logs_filter
    logging_sink_name            = "sk-c-logging-bkt"
    storage_bucket_name          = "bkt-${module.org_audit_logs.project_id}-org-logs-${random_string.suffix.result}"
    location                     = var.log_export_storage_location
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
    logging_sink_filter = local.main_logs_filter
    logging_sink_name   = "sk-c-logging-pub"
    topic_name          = "tp-org-logs-${random_string.suffix.result}"
    create_subscriber   = true
  }

  /******************************************
    Send logs to Logbucket
  *****************************************/
  logbucket_options = {
    logging_sink_name   = "sk-c-logging-logbkt"
    logging_sink_filter = local.all_logs_filter
    name                = "logbkt-org-logs-${random_string.suffix.result}"
    location            = local.default_region
  }
}


/******************************************
  Billing logs (Export configured manually)
*****************************************/

resource "google_bigquery_dataset" "billing_dataset" {
  dataset_id    = "billing_data"
  project       = module.org_billing_logs.project_id
  friendly_name = "GCP Billing Data"
  location      = var.billing_export_dataset_location
}
