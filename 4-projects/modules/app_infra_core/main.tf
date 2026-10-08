/**
 * Copyright 2026 Google LLC
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

resource "google_service_account" "app_infra_sa" {
  for_each = toset(var.app_infra_repos)

  project      = var.project_id
  account_id   = "sa-tf-${each.key}"
  display_name = "App Infra Pipeline SA for ${each.key}"
}

resource "google_storage_bucket" "state_buckets" {
  for_each = toset(var.app_infra_repos)

  project                     = var.project_id
  name                        = "${var.bucket_prefix}-${var.project_id}-${each.key}-state"
  location                    = var.default_region
  uniform_bucket_level_access = true
  force_destroy               = var.bucket_force_destroy

  versioning {
    enabled = true
  }

  dynamic "encryption" {
    for_each = var.kms_key_name != null ? [var.kms_key_name] : []
    content {
      default_kms_key_name = encryption.value
    }
  }
}

resource "google_storage_bucket_iam_member" "sa_state_bucket_admin" {
  for_each = toset(var.app_infra_repos)

  bucket = google_storage_bucket.state_buckets[each.key].name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.app_infra_sa[each.key].email}"
}

resource "google_storage_bucket_iam_member" "sa_remote_state_reader" {
  for_each = toset(var.remote_tfstate_bucket != "" ? var.app_infra_repos : [])

  bucket = var.remote_tfstate_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.app_infra_sa[each.key].email}"
}

resource "google_artifact_registry_repository" "tf_runners" {
  for_each = toset(var.app_infra_repos)

  project       = var.project_id
  location      = var.default_region
  repository_id = length(var.app_infra_repos) == 1 ? "tf-runners" : "${each.key}-tf-runners"
  description   = "Artifact Registry repository for ${each.key} runner and confidential space images"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "sa_ar_writer" {
  for_each = toset(var.app_infra_repos)

  project    = var.project_id
  location   = var.default_region
  repository = google_artifact_registry_repository.tf_runners[each.key].repository_id
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.app_infra_sa[each.key].email}"
}
