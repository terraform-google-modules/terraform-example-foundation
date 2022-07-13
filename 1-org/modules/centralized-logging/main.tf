/**
 * Copyright 2022 Google LLC
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
  // Get resources map first entry to create de unique log_export destination
  log_export_resource_dest = [for k, v in var.resources : v if k == keys(var.resources)[0]][0]

  /**
   * Create a new resources map without the first entry (explained above) to create
   * log_export and assing log writer identities required permissions
   */
  log_export_other_resources = { for k, v in var.resources : k => v if k != keys(var.resources)[0] }

  destination_uri = var.logging_target_type == "bigquery" ? module.destination_bigquery[0].destination_uri : var.logging_target_type == "pubsub" ? module.destination_pubsub[0].destination_uri : module.destination_storage[0].destination_uri

  # Bigquery sink options
  bigquery_options = var.logging_target_type == "bigquery" && var.bigquery_options != null ? var.bigquery_options : null

  //-----------------------------
  //  new_bucket_name = "${var.bucket_name}-${random_string.suffix.result}"
  //  bucket_name     = var.create_bucket ? module.logging_bucket[0].bucket.name : var.bucket_name

  //  destination_uri2     = "storage.googleapis.com/${local.bucket_name}"
  storage_sa           = data.google_storage_project_service_account.gcs_account.email_address
  logging_keyring_name = "logging_keyring_${random_string.suffix.result}"
  logging_key_name     = "logging_key"
  keys                 = [local.logging_key_name]
  enabling_data_logs   = var.data_access_logs_enabled ? ["DATA_WRITE", "DATA_READ"] : []
  parent_resource_ids  = [for parent_resource_id in local.log_exports[*].parent_resource_id : parent_resource_id]

  log_exports_first = toset([
    for value in module.log_export : value
  ])

  log_exports_others = toset([
    for value in module.log_export_other_resources : value
  ])

  log_exports = setunion(local.log_exports_first, local.log_exports_others)
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

data "google_storage_project_service_account" "gcs_account" {
  project = var.logging_destination_project_id
}

module "cmek" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.0.1"

  count = var.create_bucket ? 1 : 0

  project_id           = var.kms_project_id
  labels               = var.labels
  location             = var.logging_location
  keyring              = local.logging_keyring_name
  key_rotation_period  = var.key_rotation_period_seconds
  keys                 = local.keys
  key_protection_level = var.kms_key_protection_level
  set_encrypters_for   = local.keys
  set_decrypters_for   = local.keys
  encrypters           = ["serviceAccount:${local.storage_sa}"]
  decrypters           = ["serviceAccount:${local.storage_sa}"]
  prevent_destroy      = !var.delete_contents_on_destroy
}

module "log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.3.0"
  //  version = "~> 7.1.0"

  destination_uri        = local.destination_uri
  filter                 = var.sink_filter
  log_sink_name          = "sk-logging-to-${var.logging_destination_project_id}"
  parent_resource_id     = local.log_export_resource_dest
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
  include_children       = true
  bigquery_options       = local.bigquery_options
  exclusions             = var.exclusions
}

module "log_export_other_resources" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.3.0"
  //  version = "~> 7.1.0"

  for_each = local.log_export_other_resources

  destination_uri        = local.destination_uri
  filter                 = var.sink_filter
  log_sink_name          = "sk-logging-to-${var.logging_destination_project_id}"
  parent_resource_id     = each.value
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
}

/******************************************
  Send logs to BigQuery
*****************************************/
module "destination_bigquery" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 7.3.0"

  count = var.logging_target_type == "bigquery" ? 1 : 0

  project_id                 = var.logging_destination_project_id
  dataset_name               = "bq_logging"
  log_sink_writer_identity   = each.value.writer_identity
  expiration_days            = var.audit_logs_table_expiration_days
  delete_contents_on_destroy = var.audit_logs_table_delete_contents_on_destroy
}

#-----------------------------------------#
# Bigquery Service account IAM membership #
#-----------------------------------------#
resource "google_project_iam_member" "bigquery_sink_member" {
  for_each = var.logging_target_type == "bigquery" ? local.log_export_other_resources : {}

  project = var.logging_destination_project_id
  role    = "roles/bigquery.dataEditor"
  member  = module.log_export_other_resources[each.key].writer_identity
}

/******************************************
  Send logs to Storage
*****************************************/
module "destination_storage" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 7.3.0"

  count = var.logging_target_type == "storage" ? 1 : 0

  project_id                  = var.logging_destination_project_id
  storage_bucket_name         = "bkt-${var.logging_destination_project_id}-org-logs-${random_string.suffix.result}"
  log_sink_writer_identity    = module.log_export.writer_identity
  uniform_bucket_level_access = true
  location                    = var.logging_location
  //  retention_policy            = var.log_export_retention_policy
  //  force_destroy               = var.log_export_force_destroy
  //  versioning                  = var.log_export_versioning
}

#----------------------------------------#
# Storage Service account IAM membership #
#----------------------------------------#
resource "google_storage_bucket_iam_member" "storage_sink_member" {
  for_each = var.logging_target_type == "storage" ? module.log_export_other_resources : {}

  bucket = module.destination_storage[0].resource_name
  role   = "roles/storage.objectCreator"
  member = each.value.writer_identity
}

/******************************************
  Send logs to Pub\Sub
*****************************************/
module "destination_pubsub" {
  source  = "terraform-google-modules/log-export/google//modules/pubsub"
  version = "~> 7.3.0"

  count = var.logging_target_type == "pubsub" ? 1 : 0

  project_id               = var.logging_destination_project_id
  topic_name               = "tp-org-logs-${random_string.suffix.result}"
  log_sink_writer_identity = module.log_export.writer_identity
  create_subscriber        = true
}

#---------------------------------------#
# Pubsub Service account IAM membership #
#---------------------------------------#
resource "google_pubsub_topic_iam_member" "pubsub_sink_member" {
  for_each = var.logging_target_type == "pubsub" ? module.log_export_other_resources : {}

  project = var.logging_destination_project_id
  topic   = module.destination_pubsub[0].resource_name
  role    = "roles/pubsub.publisher"
  member  = each.value.writer_identity
}



//------------------------------------------------
/*
module "log_export_to_bucket" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.1.0"

  for_each = lookup(local.resources_map, var.logging_target_type, {})

  destination_uri        = local.destination_uri
  filter                 = var.sink_filter
  log_sink_name          = "sk-dwh-logging-bkt2"
  parent_resource_id     = each.value
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
}

module "logging_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 2.1"

  count = var.create_bucket ? 1 : 0

  name          = local.new_bucket_name
  project_id    = var.logging_destination_project_id
  location      = var.logging_location
  force_destroy = true
  encryption = {
    default_kms_key_name = module.cmek[0].keys[local.logging_key_name]
  }
}

resource "google_storage_bucket_iam_member" "storage_sink_member2" {
  for_each = module.log_export_to_bucket

  bucket = local.bucket_name
  role   = "roles/storage.objectCreator"
  member = each.value.writer_identity
}

/* TODO quando nao for projeto? */
/*
resource "google_project_iam_audit_config" "project_config" {
  for_each = var.resources

  project = "projects/${each.value}"
  service = "allServices"

  ###################################################################################################
  ### Audit logs can generate costs, to know more about it,
  ### check the official documentation: https://cloud.google.com/stackdriver/pricing#logging-costs
  ### To know more about audit logs, you can find more infos
  ### here https://cloud.google.com/logging/docs/audit/configure-data-access
  ### To enable DATA_READ and DATA_WRITE audit logs, set `data_access_logs_enabled` to true
  ### ADMIN_READ logs are enabled by default.
  ####################################################################################################
  dynamic "audit_log_config" {
    for_each = setunion(local.enabling_data_logs, ["ADMIN_READ"])
    content {
      log_type = audit_log_config.key
    }
  }
}
*/
