/**
 * Copyright 2021 Google LLC
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

module "env_secrets_project" {
  source = "../single_project"

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.env_folder_name
  environment     = var.env
  project_budget  = var.project_budget
  project_suffix  = var.secrets_prj_suffix
  project_prefix  = local.project_prefix

  activate_apis = ["logging.googleapis.com", "secretmanager.googleapis.com", "cloudkms.googleapis.com"]

  # Metadata
  application_name  = "${var.business_code}-sample-application"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}

data "google_storage_project_service_account" "gcs_account" {
  project = module.base_shared_vpc_project.project_id
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 2.1"

  project_id          = module.env_secrets_project.project_id
  keyring             = var.keyring_name
  location            = var.location_kms
  keys                = [var.key_name]
  key_rotation_period = var.key_rotation_period
  encrypters          = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
  set_encrypters_for  = [var.key_name]
  decrypters          = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
  set_decrypters_for  = [var.key_name]
  prevent_destroy     = "false"
}

resource "random_string" "bucket_name" {
  length  = 5
  upper   = false
  numeric = true
  lower   = true
  special = false
}

module "gcs_buckets" {
  source  = "terraform-google-modules/cloud-storage/google//modules/simple_bucket"
  version = "~> 3.0"

  project_id         = module.base_shared_vpc_project.project_id
  location           = var.location_gcs
  name               = "${var.gcs_bucket_prefix}-${module.base_shared_vpc_project.project_id}-${lower(var.location_gcs)}-cmek-encrypted-${random_string.bucket_name.result}"
  bucket_policy_only = true

  encryption = {
    default_kms_key_name = module.kms.keys[var.key_name]
  }

  depends_on = [module.kms]
}
