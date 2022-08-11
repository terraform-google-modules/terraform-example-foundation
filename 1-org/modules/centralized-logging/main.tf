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
  key_first_resource         = keys(var.resources)[0]
  logbucket_sink_member      = { for k, v in var.resources : k => v if k != var.logging_project_key }
  resource_name              = var.logging_target_type == "bigquery" ? module.destination_bigquery[0].resource_name : var.logging_target_type == "pubsub" ? module.destination_pubsub[0].resource_name : var.logging_target_type == "storage" ? module.destination_storage[0].resource_name : module.destination_logbucket[0].resource_name
  destination_uri            = length(var.logging_destination_uri) > 0 ? var.logging_destination_uri : var.logging_target_type == "bigquery" ? module.destination_bigquery[0].destination_uri : var.logging_target_type == "pubsub" ? module.destination_pubsub[0].destination_uri : var.logging_target_type == "storage" ? module.destination_storage[0].destination_uri : module.destination_logbucket[0].destination_uri
  create_destination         = !(length(var.logging_destination_uri) > 0)
  logging_sink_name          = length(var.logging_sink_name) > 0 ? var.logging_sink_name : "sk-to-${local.logging_target_name_prefix}-${var.logging_destination_project_id}"
  logging_target_name_prefix = var.logging_target_type == "bigquery" ? "ds" : var.logging_target_type == "pubsub" ? "topic" : var.logging_target_type == "storage" ? "bkt" : "logbkt"
  logging_target_name        = length(var.logging_target_name) > 0 ? var.logging_target_name : "${local.logging_target_name_prefix}-${random_string.suffix.result}"
  log_exports                = setunion(local.log_exports_others)
  parent_resource_ids        = [for parent_resource_id in local.log_exports[*].parent_resource_id : parent_resource_id]

  # Bigquery sink options
  bigquery_options = var.logging_target_type == "bigquery" && var.bigquery_options != null ? var.bigquery_options : null

  log_exports_others = toset([
    for value in module.log_export : value
  ])
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
}

module "log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.3.0"

  for_each = var.resources

  destination_uri        = local.destination_uri
  filter                 = var.logging_sink_filter
  log_sink_name          = local.logging_sink_name
  parent_resource_id     = each.value
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
  include_children       = var.include_children
  bigquery_options       = local.bigquery_options
  exclusions             = var.exclusions
}


#-------------------------#
# Send logs to Log Bucket #
#-------------------------#
module "destination_logbucket" {
  //  source  = "terraform-google-modules/log-export/google//modules/logbucket"
  //  version = "~> 7.4.2"

  source = "github.com/terraform-google-modules/terraform-google-log-export//modules/logbucket"

  count = local.create_destination && var.logging_target_type == "logbucket" ? 1 : 0

  project_id                    = var.logging_destination_project_id
  name                          = local.logging_target_name
  log_sink_writer_identity      = module.log_export[local.key_first_resource].writer_identity
  location                      = var.logging_location
  retention_days                = var.retention_days
  grant_write_permission_on_bkt = false
}

#-------------------------------------------#
# Log Bucket Service account IAM membership #
#-------------------------------------------#
resource "google_project_iam_member" "logbucket_sink_member" {
  for_each = var.logging_target_type == "logbucket" ? local.logbucket_sink_member : {}

  project = var.logging_destination_project_id
  role    = "roles/logging.bucketWriter"
  member  = module.log_export[each.key].writer_identity
}

#-----------------------#
# Send logs to BigQuery #
#-----------------------#
module "destination_bigquery" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 7.3.0"

  count = local.create_destination && var.logging_target_type == "bigquery" ? 1 : 0

  project_id                 = var.logging_destination_project_id
  dataset_name               = replace(local.logging_target_name, "-", "_")
  log_sink_writer_identity   = module.log_export[local.key_first_resource].writer_identity
  labels                     = var.labels
  description                = var.dataset_description
  kms_key_name               = var.kms_key_name
  expiration_days            = var.expiration_days
  delete_contents_on_destroy = var.delete_contents_on_destroy
}

#-----------------------------------------#
# Bigquery Service account IAM membership #
#-----------------------------------------#
resource "google_project_iam_member" "bigquery_sink_member" {
  for_each = var.logging_target_type == "bigquery" ? var.resources : {}

  project = var.logging_destination_project_id
  role    = "roles/bigquery.dataEditor"
  member  = module.log_export[each.key].writer_identity
}


#----------------------#
# Send logs to Storage #
#----------------------#
module "destination_storage" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 7.3.0"

  count = local.create_destination && var.logging_target_type == "storage" ? 1 : 0

  project_id                  = var.logging_destination_project_id
  storage_bucket_name         = local.logging_target_name
  log_sink_writer_identity    = module.log_export[local.key_first_resource].writer_identity
  kms_key_name                = var.kms_key_name
  uniform_bucket_level_access = var.uniform_bucket_level_access
  location                    = var.logging_location
  storage_bucket_labels       = var.labels
  force_destroy               = var.delete_contents_on_destroy
  retention_policy            = var.retention_policy
  lifecycle_rules             = var.lifecycle_rules
  storage_class               = var.storage_class
  versioning                  = var.versioning
}

#----------------------------------------#
# Storage Service account IAM membership #
#----------------------------------------#
resource "google_storage_bucket_iam_member" "storage_sink_member" {
  for_each = var.logging_target_type == "storage" ? module.log_export : {}

  bucket = module.destination_storage[0].resource_name
  role   = "roles/storage.objectCreator"
  member = each.value.writer_identity
}


#----------------------#
# Send logs to Pub\Sub #
#----------------------#
module "destination_pubsub" {
  source  = "terraform-google-modules/log-export/google//modules/pubsub"
  version = "~> 7.3.0"

  count = local.create_destination && var.logging_target_type == "pubsub" ? 1 : 0

  project_id               = var.logging_destination_project_id
  topic_name               = local.logging_target_name
  log_sink_writer_identity = module.log_export[local.key_first_resource].writer_identity
  kms_key_name             = var.kms_key_name
  topic_labels             = var.labels
  create_subscriber        = var.create_subscriber
  subscription_labels      = var.subscription_labels
  create_push_subscriber   = var.create_push_subscriber
  push_endpoint            = var.push_endpoint
  subscriber_id            = var.subscriber_id
}

#---------------------------------------#
# Pubsub Service account IAM membership #
#---------------------------------------#
resource "google_pubsub_topic_iam_member" "pubsub_sink_member" {
  for_each = var.logging_target_type == "pubsub" ? module.log_export : {}

  project = var.logging_destination_project_id
  topic   = module.destination_pubsub[0].resource_name
  role    = "roles/pubsub.publisher"
  member  = each.value.writer_identity
}
