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

module "log_export_to_biqquery" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 5.1.0"
  destination_uri        = module.bigquery_destination.destination_uri
  filter                 = local.main_logs_filter
  log_sink_name          = "sk-c-logging-bq"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
  unique_writer_identity = true
  bigquery_options = {
    use_partitioned_tables = true
  }
}

module "bigquery_destination" {
  source                     = "terraform-google-modules/log-export/google//modules/bigquery"
  version                    = "~> 5.1.0"
  project_id                 = module.org_audit_logs.project_id
  dataset_name               = "audit_logs"
  log_sink_writer_identity   = module.log_export_to_biqquery.writer_identity
  expiration_days            = var.audit_logs_table_expiration_days
  delete_contents_on_destroy = var.audit_logs_table_delete_contents_on_destroy
}

/******************************************
  Send logs to Storage
*****************************************/

module "log_export_to_storage" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 5.1.0"
  destination_uri        = module.storage_destination.destination_uri
  filter                 = local.all_logs_filter
  log_sink_name          = "sk-c-logging-bkt"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
  unique_writer_identity = true
}

module "storage_destination" {
  source                      = "terraform-google-modules/log-export/google//modules/storage"
  version                     = "~> 5.1.0"
  project_id                  = module.org_audit_logs.project_id
  storage_bucket_name         = "bkt-${module.org_audit_logs.project_id}-org-logs-${random_string.suffix.result}"
  log_sink_writer_identity    = module.log_export_to_storage.writer_identity
  uniform_bucket_level_access = true
  location                    = var.log_export_storage_location
  retention_policy            = var.log_export_storage_retention_policy
  force_destroy               = var.log_export_storage_force_destroy
  versioning                  = var.log_export_storage_versioning
}

/******************************************
  Send logs to Pub\Sub
*****************************************/

module "log_export_to_pubsub" {
  source                 = "terraform-google-modules/log-export/google"
  version                = "~> 5.1.0"
  destination_uri        = module.pubsub_destination.destination_uri
  filter                 = local.main_logs_filter
  log_sink_name          = "sk-c-logging-pub"
  parent_resource_id     = local.parent_resource_id
  parent_resource_type   = local.parent_resource_type
  include_children       = true
  unique_writer_identity = true
}

module "pubsub_destination" {
  source                   = "terraform-google-modules/log-export/google//modules/pubsub"
  version                  = "~> 5.1.0"
  project_id               = module.org_audit_logs.project_id
  topic_name               = "tp-org-logs-${random_string.suffix.result}"
  log_sink_writer_identity = module.log_export_to_pubsub.writer_identity
  create_subscriber        = true
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
