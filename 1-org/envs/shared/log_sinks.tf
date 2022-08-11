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
  parent_resource_id   = var.parent_folder != "" ? var.parent_folder : var.org_id
  parent_resource_type = var.parent_folder != "" ? "folder" : "organization"
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

/******************************************
  Send logs to BigQuery
*****************************************/

module "bigquery_destination" {
  source = "../../modules/centralized-logging"

  resources           = local.parent_resources
  resource_type       = local.parent_resource_type
  logging_sink_filter = local.main_logs_filter
  logging_sink_name   = "sk-c-logging-bq"
  logging_target_type = "bigquery"
  include_children    = true
  bigquery_options = {
    use_partitioned_tables = true
  }
  logging_destination_project_id = module.org_audit_logs.project_id
  logging_target_name            = "audit_logs"
  expiration_days                = var.audit_logs_table_expiration_days
  delete_contents_on_destroy     = var.audit_logs_table_delete_contents_on_destroy
}

/******************************************
  Send logs to Storage
*****************************************/

module "storage_destination" {
  source = "../../modules/centralized-logging"

  logging_sink_filter            = local.all_logs_filter
  logging_sink_name              = "sk-c-logging-bkt"
  resources                      = local.parent_resources
  resource_type                  = local.parent_resource_type
  include_children               = true
  logging_target_type            = "storage"
  logging_destination_project_id = module.org_audit_logs.project_id
  logging_target_name            = "bkt-${module.org_audit_logs.project_id}-org-logs-${random_string.suffix.result}"
  uniform_bucket_level_access    = true
  logging_location               = var.log_export_storage_location
  retention_policy               = var.log_export_storage_retention_policy
  delete_contents_on_destroy     = var.log_export_storage_force_destroy
  versioning                     = var.log_export_storage_versioning
}

/******************************************
  Send logs to Pub\Sub
*****************************************/

module "pubsub_destination" {
  source = "../../modules/centralized-logging"

  logging_sink_filter            = local.main_logs_filter
  logging_sink_name              = "sk-c-logging-pub"
  resources                      = local.parent_resources
  resource_type                  = local.parent_resource_type
  include_children               = true
  logging_target_type            = "pubsub"
  logging_destination_project_id = module.org_audit_logs.project_id
  logging_target_name            = "tp-org-logs-${random_string.suffix.result}"
  create_subscriber              = true
}

/******************************************
  Send logs to Logbucket
*****************************************/
module "logbucket_destination" {
  source = "../../modules/centralized-logging"

  logging_sink_filter            = local.all_logs_filter
  logging_sink_name              = "sk-c-logging-logbkt"
  resources                      = local.parent_resources
  resource_type                  = local.parent_resource_type
  include_children               = true
  logging_target_type            = "logbucket"
  logging_destination_project_id = module.org_audit_logs.project_id
  logging_target_name            = "logbkt-${module.org_audit_logs.project_id}-org-logs-${random_string.suffix.result}"
  logging_location               = var.default_region
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
