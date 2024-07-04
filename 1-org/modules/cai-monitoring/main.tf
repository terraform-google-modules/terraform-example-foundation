/**
 * Copyright 2023 Google LLC
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
  project_service_apis = [
    "cloudresourcemanager.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudasset.googleapis.com",
    "pubsub.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
    "run.googleapis.com",
    "eventarc.googleapis.com"
  ]
  cai_source_name = var.random_suffix ? "CAI Monitoring - ${random_id.suffix.hex}" : "CAI Monitoring"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "random_id" "suffix" {
  byte_length = 2
}

// Project Services
resource "google_project_service" "services" {
  for_each = toset(local.project_service_apis)

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

// Artifact Registry
resource "google_artifact_registry_repository" "cloudfunction" {
  location      = var.location
  project       = var.project_id
  repository_id = "ar-cai-monitoring-${random_id.suffix.hex}"
  description   = "This repo stores de image of the cloud function."
  format        = "DOCKER"
  kms_key_name  = var.encryption_key
  labels        = var.labels

  depends_on = [
    time_sleep.wait_kms_iam
  ]
}

// Bucket and function source code
data "archive_file" "function_source_zip" {
  type        = "zip"
  source_dir  = "${path.module}/function-source/"
  output_path = "${path.module}/cai_monitoring.zip"
  excludes    = ["package-lock.json"]
}

module "cloudfunction_source_bucket" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 6.0"

  project_id    = var.project_id
  name          = "bkt-cai-monitoring-${random_id.suffix.hex}-sources-${data.google_project.project.number}-${var.location}"
  location      = var.location
  storage_class = "REGIONAL"
  force_destroy = true

  encryption = var.enable_cmek ? {
    default_kms_key_name = var.encryption_key
  } : null

  depends_on = [
    time_sleep.wait_kms_iam
  ]
}

resource "time_sleep" "wait_for_bucket" {
  depends_on      = [module.cloudfunction_source_bucket]
  create_duration = "30s"
}

resource "google_storage_bucket_object" "cf_cai_source_zip" {
  name   = "${path.module}/cai_monitoring.zip"
  bucket = module.cloudfunction_source_bucket.name
  source = data.archive_file.function_source_zip.output_path

  depends_on = [
    time_sleep.wait_for_bucket
  ]
}

// PubSub
resource "google_cloud_asset_organization_feed" "organization_feed" {
  feed_id         = "fd-cai-monitoring-${random_id.suffix.hex}"
  billing_project = var.project_id
  org_id          = var.org_id
  content_type    = "IAM_POLICY"

  asset_types = [".*"]

  feed_output_config {
    pubsub_destination {
      topic = module.pubsub_cai_feed.id
    }
  }
}

module "pubsub_cai_feed" {
  source  = "terraform-google-modules/pubsub/google"
  version = "~> 6.0"

  topic              = "top-cai-monitoring-${random_id.suffix.hex}-event"
  project_id         = var.project_id
  topic_kms_key_name = var.encryption_key

  depends_on = [
    time_sleep.wait_kms_iam
  ]
}

// SCC source
resource "google_scc_source" "cai_monitoring" {
  display_name = local.cai_source_name
  organization = var.org_id
  description  = "SCC Finding Source for caiMonitoring Cloud Functions."
}

// Cloud Function
module "cloud_function" {
  source  = "GoogleCloudPlatform/cloud-functions/google"
  version = "~> 0.6"

  function_name         = "caiMonitoring"
  description           = "Check on the Organization for members (users, groups and service accounts) that contains the IAM roles listed."
  project_id            = var.project_id
  labels                = var.labels
  function_location     = var.location
  runtime               = "nodejs20"
  entrypoint            = "caiMonitoring"
  docker_repository     = google_artifact_registry_repository.cloudfunction.id
  build_service_account = var.build_service_account

  storage_source = {
    bucket = module.cloudfunction_source_bucket.name
    object = google_storage_bucket_object.cf_cai_source_zip.name
  }

  service_config = {
    service_account_email = google_service_account.cloudfunction.email
    runtime_env_variables = {
      ROLES            = join(",", var.roles_to_monitor)
      SOURCE_ID        = google_scc_source.cai_monitoring.id
      LOG_EXECUTION_ID = "true"
    }
  }

  event_trigger = {
    trigger_region        = var.location
    event_type            = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic          = module.pubsub_cai_feed.id
    retry_policy          = "RETRY_POLICY_RETRY"
    service_account_email = google_service_account.cloudfunction.email
  }

  depends_on = [
    google_storage_bucket_object.cf_cai_source_zip,
    time_sleep.wait_kms_iam
  ]
}
