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
  Permission for Terraform Cloud Bucket
*******************************************/

resource "google_storage_bucket_iam_member" "terraform_backend" {
  bucket = google_storage_bucket.terraform_backend.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
}

/******************************************
  Permissions to decrypt
 *****************************************/

resource "google_kms_crypto_key_iam_binding" "cloudbuild_crypto_key_decrypter" {
  crypto_key_id = google_kms_crypto_key.tf_key.self_link
  role          = "roles/cloudkms.cryptoKeyDecrypter"

  members = [
    "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
  ]
  depends_on = [google_cloudbuild_trigger.master_trigger, google_cloudbuild_trigger.non_master_trigger]
}

/******************************************
  Permissions for application admins to encrypt
 *****************************************/

resource "google_kms_crypto_key_iam_binding" "cloud_build_crypto_key_encrypter" {
  crypto_key_id = google_kms_crypto_key.tf_key.self_link
  role          = "roles/cloudkms.cryptoKeyEncrypter"

  members = [
    "group:${var.admin_group}",
  ]
}

/******************************************
  Service Account
*******************************************/

resource "google_service_account" "children_nonprod" {
  count = local.application_project_nonprod != "" ? 1 : 0

  project     = module.project.project_id
  account_id  = local.application_project_nonprod
  description = "Service account for application project infrastructure Cloud Build for Nonprod Environment"
}

resource "google_service_account" "children_prod" {
  count = local.application_project_prod != "" ? 1 : 0

  project     = module.project.project_id
  account_id  = local.application_project_prod
  description = "Service account for application project infrastructure Cloud Build for Prod Environment"
}

/******************************************
  Permission for Service Account Impersonation
*******************************************/

resource "google_service_account_iam_member" "impersonate_nonprod" {
  count = local.application_project_nonprod != "" ? 1 : 0

  service_account_id = local.application_sa_name_nonprod
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
  depends_on         = [google_cloudbuild_trigger.master_trigger, google_cloudbuild_trigger.non_master_trigger]
}

resource "google_service_account_iam_member" "impersonate_prod" {
  count = local.application_project_prod != "" ? 1 : 0

  service_account_id = local.application_sa_name_prod
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${module.project.project_number}@cloudbuild.gserviceaccount.com"
  depends_on         = [google_cloudbuild_trigger.master_trigger, google_cloudbuild_trigger.non_master_trigger]
}

/******************************************
  Project Editor Permission
*******************************************/

resource "google_project_iam_member" "editor_nonprod" {
  count = local.application_project_nonprod != "" ? 1 : 0

  project = local.application_project_nonprod
  member  = "serviceAccount:${local.application_sa_email_nonprod}"
  role    = "roles/editor"
}

resource "google_project_iam_member" "editor_prod" {
  count = local.application_project_prod != "" ? 1 : 0

  project = local.application_project_prod
  member  = "serviceAccount:${local.application_sa_email_prod}"
  role    = "roles/editor"
}

/******************************************
  Network Permission
*******************************************/

resource "google_compute_subnetwork_iam_member" "host_network_user_nonprod" {
  count = local.application_project_nonprod != "" ? 1 : 0

  project    = local.network_project_nonprod
  region     = var.default_region
  subnetwork = var.subnetwork_name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${local.application_sa_email_nonprod}"
}

resource "google_compute_subnetwork_iam_member" "host_network_user_prod" {
  count = local.application_project_prod != "" ? 1 : 0

  project    = local.network_project_prod
  region     = var.default_region
  subnetwork = var.subnetwork_name
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${local.application_sa_email_prod}"
}

