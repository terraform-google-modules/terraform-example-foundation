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

  all_sinks = merge(
    var.bigquery_options == null ? {} : {
      for k, v in var.resources : "${v}_bgq" => var.bigquery_options
    },
    var.logbucket_options == null ? {} : {
      for k, v in var.resources : "${v}_lbk" => var.logbucket_options
    },
    var.pubsub_options == null ? {} : {
      for k, v in var.resources : "${v}_pub" => var.pubsub_options
    },
    var.storage_options == null ? {} : {
      for k, v in var.resources : "${v}_sto" => var.storage_options
    },
  )

  logging_sink_name_map = {
    bgq = try("ds-logs-${var.logging_destination_project_id}", "ds-logs")
    pub = try("tp-logs-${var.logging_destination_project_id}", "tp-logs")
    sto = try("bkt-logs-${var.logging_destination_project_id}", "bkt-logs")
    lbk = try("logbkt-logs-${var.logging_destination_project_id}", "logbkt-logs")
  }
  destination_uri_map = {
    bgq = try(module.destination_bigquery[0].destination_uri, "")
    pub = try(module.destination_pubsub[0].destination_uri, "")
    sto = try(module.destination_storage[0].destination_uri, "")
    lbk = try(module.destination_logbucket[0].destination_uri, "")
  }
  logging_target_name_prefix = {
    bgq = "ds_logs_"
    pub = "tp-logs-"
    sto = try("bkt-logs-${var.logging_destination_project_id}-", "bkt-logs-")
    lbk = "logbkt-logs-"
  }

  part_tables = {
    false = { use_partitioned_tables = false }
    true  = { use_partitioned_tables = true }
  }

  bgq_options_part_tables = var.bigquery_options == null ? local.part_tables.false : !contains(keys(var.bigquery_options), "partitioned_tables") ? local.part_tables.false : var.bigquery_options.partitioned_tables == "true" ? local.part_tables.true : local.part_tables.false
}

resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

module "log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.3.0"

  for_each = local.all_sinks

  destination_uri        = lookup(each.value, "destination_uri", lookup(local.destination_uri_map, substr(each.key, -3, -1), ""))
  filter                 = lookup(each.value, "logging_sink_filter", "")
  log_sink_name          = lookup(each.value, "logging_sink_name", "sk-to-${lookup(local.logging_sink_name_map, substr(each.key, -3, -1), "log_dest_")}")
  parent_resource_id     = substr(each.key, 0, length(each.key) - 4)
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
  include_children       = tobool(lookup(each.value, "include_children", "false"))
  bigquery_options       = substr(each.key, -3, -1) == "bgq" ? local.bgq_options_part_tables : null
}

#-------------------------#
# Send logs to Log Bucket #
#-------------------------#
module "destination_logbucket" {
  //  source  = "terraform-google-modules/log-export/google//modules/logbucket"
  //  version = "~> 7.4.2"

  source = "github.com/terraform-google-modules/terraform-google-log-export//modules/logbucket"

  count = var.logbucket_options != null ? 1 : 0

  project_id                    = var.logging_destination_project_id
  name                          = lookup(var.logbucket_options, "name", "${lookup(local.logging_target_name_prefix, "lbk", "log_dest_")}${random_string.suffix.result}")
  log_sink_writer_identity      = module.log_export["${local.value_first_resource}_lbk"].writer_identity
  location                      = lookup(var.logbucket_options, "location", "global")
  retention_days                = lookup(var.logbucket_options, "retention_days", 30)
  grant_write_permission_on_bkt = false
}

#-------------------------------------------#
# Log Bucket Service account IAM membership #
#-------------------------------------------#
resource "google_project_iam_member" "logbucket_sink_member" {
  for_each = var.logbucket_options != null ? local.logbucket_sink_member : {}

  project = var.logging_destination_project_id
  role    = "roles/logging.bucketWriter"
  member  = module.log_export["${each.value}_lbk"].writer_identity
}


#-----------------------#
# Send logs to BigQuery #
#-----------------------#
module "destination_bigquery" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "~> 7.3.0"

  count = var.bigquery_options != null ? 1 : 0

  project_id                 = var.logging_destination_project_id
  dataset_name               = replace(lookup(var.bigquery_options, "dataset_name", "${lookup(local.logging_target_name_prefix, "bgq", "log_dest_")}${random_string.suffix.result}"), "-", "_")
  log_sink_writer_identity   = module.log_export["${local.value_first_resource}_bgq"].writer_identity
  expiration_days            = lookup(var.bigquery_options, "expiration_days", null)
  delete_contents_on_destroy = lookup(var.bigquery_options, "delete_contents_on_destroy", false)
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
  version = "~> 7.3.0"

  count = var.storage_options != null ? 1 : 0

  project_id                  = var.logging_destination_project_id
  storage_bucket_name         = lookup(var.storage_options, "storage_bucket_name", "${lookup(local.logging_target_name_prefix, "sto", "log_dest_")}${random_string.suffix.result}")
  log_sink_writer_identity    = module.log_export["${local.value_first_resource}_sto"].writer_identity
  uniform_bucket_level_access = true
  location                    = lookup(var.storage_options, "location", "US")
  force_destroy               = lookup(var.storage_options, "force_destroy", "false")
  versioning                  = lookup(var.storage_options, "versioning", "false")

  retention_policy = !contains(keys(var.storage_options), "retention_policy_is_locked") ? null : {
    is_locked             = tobool(lookup(var.storage_options, "retention_policy_is_locked", "false"))
    retention_period_days = tonumber(lookup(var.storage_options, "retention_policy_period_days", "30"))
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
  version = "~> 7.3.0"

  count = var.pubsub_options != null ? 1 : 0

  project_id               = var.logging_destination_project_id
  topic_name               = lookup(var.pubsub_options, "topic_name", "${lookup(local.logging_target_name_prefix, "pub", "log_dest_")}${random_string.suffix.result}")
  log_sink_writer_identity = module.log_export["${local.value_first_resource}_pub"].writer_identity
  create_subscriber        = lookup(var.pubsub_options, "create_subscriber", false)
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
