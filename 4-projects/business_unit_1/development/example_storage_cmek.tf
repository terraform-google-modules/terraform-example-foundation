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
  source                      = "../../modules/single_project"
  impersonate_service_account = var.terraform_service_account
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = data.google_active_folder.env.name
  environment                 = "development"
  alert_spent_percents        = var.alert_spent_percents
  alert_pubsub_topic          = var.alert_pubsub_topic
  budget_amount               = var.budget_amount
  project_suffix              = "env-secrets"

  activate_apis = ["logging.googleapis.com", "secretmanager.googleapis.com", "cloudkms.googleapis.com"]

  # Metadata
  application_name  = "bu1-sample-application"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu1"
}

data "google_storage_project_service_account" "gcs_account" {
  project = module.base_shared_vpc_project.project_id
}

module "kms" {
  source  = "terraform-google-modules/kms/google"
  version = "~> 1.2"

  project_id          = module.env_secrets_project.project_id
  keyring             = "sample-keyring"
  location            = "global"
  keys                = ["crypto-key-example"]
  key_rotation_period = "7776000s" # 90 days
  encrypters          = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
  set_encrypters_for  = ["crypto-key-example"]
  prevent_destroy     = "false"
}

resource "random_string" "bucket_name" {
  length  = 5
  upper   = false
  number  = true
  lower   = true
  special = false
}

module "gcs_buckets" {
  source               = "terraform-google-modules/cloud-storage/google"
  version              = "~> 1.7"
  project_id           = module.base_shared_vpc_project.project_id
  names                = [random_string.bucket_name.result]
  prefix               = "cmek-encrypted-bucket"
  encryption_key_names = module.kms.keys
  depends_on           = [random_string.bucket_name]
}
