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
  value_first_resource  = values(var.resources)[0]
  logbucket_sink_member = { for k, v in var.resources : k => v if k != var.logging_project_key }
  include_children      = (var.resource_type == "organization" || var.resource_type == "folder")

  # Create an intermediate list with all resources X all destinations
  exports_list = flatten([
    # Iterate in all resources
    for res_k, res_v in var.resources : [
      # Iterate in all log destinations
      for dest_k, dest_v in local.destinations_options : {
        # Create an object that is the base for a map creation below
        "res"     = res_v,
        "options" = dest_v,
        "type"    = dest_k
      } if dest_v != null
    ]
  ])

  # Create a map based on the intermediate list above
  # with keys "<resource>_<dest>" that is used by iam permissions on destinations
  log_exports = {
    for v in local.exports_list : "${v.res}_${v.type}" => v
  }
  destinations_options = {
    bgq = var.bigquery_options
    pub = var.pubsub_options
    sto = var.storage_options
    lbk = var.logbucket_options
  }

  logging_sink_name_map = {
    bgq = try("sk-to-ds-logs-${var.logging_destination_project_id}", "sk-to-ds-logs")
    pub = try("sk-to-tp-logs-${var.logging_destination_project_id}", "sk-to-tp-logs")
    sto = try("sk-to-bkt-logs-${var.logging_destination_project_id}", "sk-to-bkt-logs")
    lbk = try("sk-to-logbkt-logs-${var.logging_destination_project_id}", "sk-to-logbkt-logs")
  }

  logging_tgt_name = {
    bgq = replace("${local.logging_tgt_prefix.bgq}${random_string.suffix.result}", "-", "_")
    pub = "${local.logging_tgt_prefix.pub}${random_string.suffix.result}"
    sto = "${local.logging_tgt_prefix.sto}${random_string.suffix.result}"
    lbk = "${local.logging_tgt_prefix.lbk}${random_string.suffix.result}"
  }

  destination_uri_map = {
    bgq = try(module.destination_bigquery[0].destination_uri, "")
    pub = try(module.destination_pubsub[0].destination_uri, "")
    sto = try(module.destination_storage[0].destination_uri, "")
    lbk = try(module.destination_logbucket[0].destination_uri, "")
  }
  logging_tgt_prefix = {
    bgq = "ds_logs_"
    pub = "tp-logs-"
    sto = try("bkt-logs-${var.logging_destination_project_id}-", "bkt-logs-")
    lbk = "logbkt-logs-"
  }
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.4"

  for_each = local.log_exports

  destination_uri        = local.destination_uri_map[each.value.type]
  filter                 = each.value.options.logging_sink_filter
  log_sink_name          = coalesce(each.value.options.logging_sink_name, local.logging_sink_name_map[each.value.type])
  parent_resource_id     = each.value.res
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
  include_children       = local.include_children
  bigquery_options       = each.value.type == "bgq" ? { use_partitioned_tables = true } : null
}

#-------------------------#
# Send logs to Log Bucket #
#-------------------------#
module "destination_logbucket" {
  source  = "terraform-google-modules/log-export/google//modules/logbucket"
  version = "~> 7.4.2"

  count = var.logbucket_options != null ? 1 : 0

  project_id                    = var.logging_destination_project_id
  name                          = coalesce(var.logbucket_options.name, local.logging_tgt_name.lbk)
  log_sink_writer_identity      = module.log_export["${local.value_first_resource}_lbk"].writer_identity
  location                      = var.logbucket_options.location
  retention_days                = var.logbucket_options.retention_days
  grant_write_permission_on_bkt = false
}

#-------------------------------------------#
# Log Bucket Service account IAM membership #
#-------------------------------------------#
resource "google_project_iam_member" "logbucket_sink_member" {
  for_each = var.logbucket_options != null ? local.logbucket_sink_member : {}

  project = var.logging_destination_project_id
  role    = "roles/logging.bucketWriter"

  # Set permission only on sinks for this destination using
  # module.log_export key "<resource>_<dest>"
  member = module.log_export["${each.value}_lbk"].writer_identity
}


#-----------------------#
# Send logs to BigQuery #
#-----------------------#
module "destination_bigquery" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 7.4"

  count = var.bigquery_options != null ? 1 : 0

  project_id                 = var.logging_destination_project_id
  dataset_name               = coalesce(var.bigquery_options.dataset_name, local.logging_tgt_name.bgq)
  log_sink_writer_identity   = module.log_export["${local.value_first_resource}_bgq"].writer_identity
  expiration_days            = var.bigquery_options.expiration_days
  delete_contents_on_destroy = var.bigquery_options.delete_contents_on_destroy
}

#-----------------------------------------#
# Bigquery Service account IAM membership #
#-----------------------------------------#
resource "google_project_iam_member" "bigquery_sink_member" {
  for_each = var.bigquery_options != null ? var.resources : {}

  project = var.logging_destination_project_id
  role    = "roles/bigquery.dataEditor"
  member  = module.log_export["${each.value}_bgq"].writer_identity
}


#----------------------#
# Send logs to Storage #
#----------------------#
module "destination_storage" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 7.4"

  count = var.storage_options != null ? 1 : 0

  project_id                  = var.logging_destination_project_id
  storage_bucket_name         = coalesce(var.storage_options.storage_bucket_name, local.logging_tgt_name.sto)
  log_sink_writer_identity    = module.log_export["${local.value_first_resource}_sto"].writer_identity
  uniform_bucket_level_access = true
  location                    = var.storage_options.location
  force_destroy               = var.storage_options.force_destroy
  versioning                  = var.storage_options.versioning

  retention_policy = !var.storage_options.retention_policy_enabled ? null : {
    is_locked             = var.storage_options.retention_policy_is_locked
    retention_period_days = var.storage_options.retention_policy_period_days
  }
}

#----------------------------------------#
# Storage Service account IAM membership #
#----------------------------------------#
resource "google_storage_bucket_iam_member" "storage_sink_member" {
  for_each = var.storage_options != null ? var.resources : {}

  bucket = module.destination_storage[0].resource_name
  role   = "roles/storage.objectCreator"
  member = module.log_export["${each.value}_sto"].writer_identity
}


#----------------------#
# Send logs to Pub\Sub #
#----------------------#
module "destination_pubsub" {
  source  = "terraform-google-modules/log-export/google//modules/pubsub"
  version = "~> 7.4"

  count = var.pubsub_options != null ? 1 : 0

  project_id               = var.logging_destination_project_id
  topic_name               = coalesce(var.pubsub_options.topic_name, local.logging_tgt_name.pub)
  log_sink_writer_identity = module.log_export["${local.value_first_resource}_pub"].writer_identity
  create_subscriber        = var.pubsub_options.create_subscriber
}

#---------------------------------------#
# Pubsub Service account IAM membership #
#---------------------------------------#
resource "google_pubsub_topic_iam_member" "pubsub_sink_member" {
  for_each = var.pubsub_options != null ? var.resources : {}

  project = var.logging_destination_project_id
  topic   = module.destination_pubsub[0].resource_name
  role    = "roles/pubsub.publisher"
  member  = module.log_export["${each.value}_pub"].writer_identity
}
