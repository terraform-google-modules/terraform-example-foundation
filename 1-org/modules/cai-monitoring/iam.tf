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
  cf_roles = [
    "roles/pubsub.publisher",
    "roles/eventarc.eventReceiver",
    "roles/run.invoker"
  ]
}

// Service Accounts
resource "google_project_service_identity" "cloudfunction_sa" {
  provider = google-beta

  project = var.project_id
  service = "cloudfunctions.googleapis.com"
}

resource "google_project_service_identity" "artifact_sa" {
  provider = google-beta

  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service_identity" "pubsub_sa" {
  provider = google-beta

  project = var.project_id
  service = "pubsub.googleapis.com"
}

data "google_storage_project_service_account" "gcs_sa" {
  project = var.project_id
}

// Roles and permissions
resource "google_kms_crypto_key_iam_member" "cloudfunction_sa_crypto_key" {
  crypto_key_id = var.encryption_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.cloudfunction_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "artifact_sa_crypto_key" {
  crypto_key_id = var.encryption_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.artifact_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "pubsub_sa_crypto_key" {
  crypto_key_id = var.encryption_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.pubsub_sa.email}"
}

resource "google_kms_crypto_key_iam_member" "storage_sa_crypto_key" {
  crypto_key_id = var.encryption_key
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = data.google_storage_project_service_account.gcs_sa.member
}

// Cloud Function SA
resource "google_service_account" "cloudfunction_sa" {
  account_id = "cai-notification"
  project    = var.project_id
}

resource "google_project_iam_member" "cloudfunction_sa_iam" {
  for_each = toset(local.cf_roles)

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cloudfunction_sa.email}"
}

// Time sleep
resource "time_sleep" "wait_kms_iam" {
  create_duration = "60s"
  depends_on = [
    google_kms_crypto_key_iam_member.cloudfunction_sa_crypto_key,
    google_kms_crypto_key_iam_member.artifact_sa_crypto_key,
    google_kms_crypto_key_iam_member.pubsub_sa_crypto_key,
    google_kms_crypto_key_iam_member.storage_sa_crypto_key,
    google_project_iam_member.cloudfunction_sa_iam
  ]
}
