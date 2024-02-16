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
    pub = var.pubsub_options
    sto = var.storage_options
    lbk = var.logbucket_options
    prj = var.project_options
  }

  logging_sink_name_map = {
    pub = try("sk-to-tp-logs-${var.logging_destination_project_id}", "sk-to-tp-logs")
    sto = try("sk-to-bkt-logs-${var.logging_destination_project_id}", "sk-to-bkt-logs")
    lbk = try("sk-to-logbkt-logs-${var.logging_destination_project_id}", "sk-to-logbkt-logs")
    prj = try("sk-to-prj-logs-${var.logging_destination_project_id}", "sk-to-prj-logs")
  }

  logging_tgt_name = {
    pub = "${local.logging_tgt_prefix.pub}${random_string.suffix.result}"
    sto = "${local.logging_tgt_prefix.sto}${random_string.suffix.result}"
    lbk = "${local.logging_tgt_prefix.lbk}${random_string.suffix.result}"
    prj = ""
  }

  destination_uri_map = {
    pub = try(module.destination_pubsub[0].destination_uri, "")
    sto = try(module.destination_storage[0].destination_uri, "")
    lbk = try(module.destination_logbucket[0].destination_uri, "")
    prj = try(module.destination_project[0].destination_uri, "")
  }

  logging_tgt_prefix = {
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
  version = "~> 7.8"

  for_each = local.log_exports

  destination_uri        = local.destination_uri_map[each.value.type]
  filter                 = each.value.options.logging_sink_filter
  log_sink_name          = coalesce(each.value.options.logging_sink_name, local.logging_sink_name_map[each.value.type])
  parent_resource_id     = each.value.res
  parent_resource_type   = var.resource_type
  unique_writer_identity = true
  include_children       = local.include_children
}

module "log_export_billing" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.8"

  for_each = var.enable_billing_account_sink ? local.log_exports : {}

  destination_uri        = local.destination_uri_map[each.value.type]
  filter                 = ""
  log_sink_name          = "${coalesce(each.value.options.logging_sink_name, local.logging_sink_name_map[each.value.type])}_billing"
  parent_resource_id     = var.billing_account
  parent_resource_type   = "billing_account"
  unique_writer_identity = true
}

#--------------------------#
# Send logs to Log project #
#--------------------------#

module "destination_project" {
  source  = "terraform-google-modules/log-export/google//modules/project"
  version = "~> 7.8"
  count   = var.project_options != null ? 1 : 0

  project_id               = var.logging_destination_project_id
  log_sink_writer_identity = module.log_export["${local.value_first_resource}_prj"].writer_identity
}

#-----------------------------------------------#
# Send logs to Log project - Default Log bucket #
#-----------------------------------------------#

resource "google_logging_project_bucket_config" "prj_logs_bucket" {
  count = var.project_options != null ? 1 : 0

  project          = var.logging_destination_project_id
  bucket_id        = coalesce(var.project_options.log_bucket_id, "logbkt-prj-logs")
  description      = var.project_options.log_bucket_description
  location         = var.project_options.location
  retention_days   = var.project_options.retention_days
  enable_analytics = var.project_options.enable_analytics
}

#------------------------------------------------------------#
# Send logs to Log project - Default Linked BigQuery dataset #
#------------------------------------------------------------#

resource "google_logging_linked_dataset" "prj_logs_linked_dataset" {
  count = var.project_options != null && var.project_options.enable_analytics ? 1 : 0

  link_id     = coalesce(var.project_options.linked_dataset_id, "ds_c_prj_logbkt_analytics")
  description = var.project_options.linked_dataset_description
  location    = var.project_options.location
  parent      = "projects/${var.logging_destination_project_id}"
  bucket      = google_logging_project_bucket_config.prj_logs_bucket[0].id
}

#-----------------------------------------------#
# Send logs to Log project - Internal Log sink #
#-----------------------------------------------#

module "internal_project_log_export" {
  source  = "terraform-google-modules/log-export/google"
  version = "~> 7.8"

  destination_uri      = "logging.googleapis.com/projects/${var.logging_destination_project_id}/locations/${var.project_options.location}/buckets/${var.project_options.log_bucket_id}"
  filter               = var.project_options.logging_sink_filter
  log_sink_name        = coalesce(var.project_options.logging_sink_name, local.logging_sink_name_map["prj"])
  parent_resource_id   = var.logging_destination_project_id
  parent_resource_type = "project"
}

#-------------------------#
# Send logs to Log Bucket #
#-------------------------#
module "destination_logbucket" {
  source  = "terraform-google-modules/log-export/google//modules/logbucket"
  version = "~> 7.8"

  count = var.logbucket_options != null ? 1 : 0

  project_id                    = var.logging_destination_project_id
  name                          = coalesce(var.logbucket_options.name, local.logging_tgt_name.lbk)
  log_sink_writer_identity      = module.log_export["${local.value_first_resource}_lbk"].writer_identity
  location                      = var.logbucket_options.location
  enable_analytics              = var.logbucket_options.enable_analytics
  linked_dataset_id             = var.logbucket_options.linked_dataset_id
  linked_dataset_description    = var.logbucket_options.linked_dataset_description
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

#----------------------#
# Send logs to Storage #
#----------------------#
module "destination_storage" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "~> 7.8"

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
  version = "~> 7.8"

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
