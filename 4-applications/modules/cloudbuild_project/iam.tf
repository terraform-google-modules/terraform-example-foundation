/**
 * Copyright 2020 Google LLC
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

/******************************************
  Service Account
*******************************************/
resource "google_service_account" "children" {
  project = module.project.project_id

  for_each    = toset(local.application_projects)
  account_id  = each.value
  description = "Service account for application project infrastructure Cloud Build"
}

/******************************************
  IAM Role - Cloud Build Service Account
*******************************************/
resource "google_service_account_iam_member" "impersonate" {
  for_each = google_service_account.children

  service_account_id = each.value.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
  depends_on         = [google_cloudbuild_trigger.master_trigger, google_cloudbuild_trigger.non_master_trigger]
}

resource "google_storage_bucket_iam_member" "terraform_backend" {
  bucket = google_storage_bucket.terraform_backend.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
}

/******************************************
  IAM Role - Application Project Service Account
*******************************************/
resource "google_project_iam_member" "editor" {
  for_each = google_service_account.children

  project = each.key
  member  = "serviceAccount:${each.value.email}"
  role    = "roles/editor"
}

/******************************************
  KMS Key
 *****************************************/

resource "google_kms_crypto_key" "tf_key" {
  name     = "tf-key"
  key_ring = google_kms_key_ring.tf_keyring.self_link
}

/******************************************
  Permissions to decrypt.
 *****************************************/
resource "google_kms_crypto_key_iam_binding" "cloudbuild_crypto_key_decrypter" {
  crypto_key_id = google_kms_crypto_key.tf_key.self_link
  role          = "roles/cloudkms.cryptoKeyDecrypter"

  members = [
    "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
  ]
  depends_on = [google_cloudbuild_trigger.master_trigger, google_cloudbuild_trigger.non_master_trigger]
}
