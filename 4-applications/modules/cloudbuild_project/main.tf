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

locals {
  application_filtered_projects_nonprod = data.google_projects.application_projects_nonprod.projects.*.project_id
  application_filtered_projects_prod    = data.google_projects.application_projects_prod.projects.*.project_id

  application_project_nonprod = length(local.application_filtered_projects_nonprod) == 1 ? local.application_filtered_projects_nonprod[0] : ""
  application_project_prod    = length(local.application_filtered_projects_prod) == 1 ? local.application_filtered_projects_prod[0] : ""

  network_project_nonprod = data.google_projects.network_projects_nonprod.projects[0].project_id
  network_project_prod    = data.google_projects.network_projects_prod.projects[0].project_id

  application_sa_name_nonprod = local.application_project_nonprod != "" ? google_service_account.children_nonprod[0].name : ""
  application_sa_name_prod    = local.application_project_prod != "" ? google_service_account.children_prod[0].name : ""

  application_sa_email_nonprod = local.application_project_nonprod != "" ? google_service_account.children_nonprod[0].email : ""
  application_sa_email_prod    = local.application_project_prod != "" ? google_service_account.children_prod[0].email : ""

  cloudbuild_envs = merge(
    local.application_project_nonprod != "" ?
    {
      _SA_EMAIL_NONPROD           = local.application_sa_email_nonprod
      _APP_PROJECT_NONPROD        = local.application_project_nonprod
      _NETWORK_PROJECT_ID_NONPROD = local.network_project_nonprod
    } : {},
    local.application_project_prod != "" ?
    {
      _SA_EMAIL_PROD           = local.application_sa_email_prod
      _APP_PROJECT_PROD        = local.application_project_prod
      _NETWORK_PROJECT_ID_PROD = local.network_project_prod
    } : {},
  )
}

/******************************************
  Create Project for Cloud Build
*******************************************/
module "project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 7.0"
  random_project_id           = "true"
  impersonate_service_account = var.impersonate_service_account
  activate_apis               = ["cloudbuild.googleapis.com", "sourcerepo.googleapis.com", "cloudkms.googleapis.com"]
  name                        = "${var.project_prefix}-util"
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = data.google_active_folder.util.name

  labels = {
    environment      = "util"
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

/******************************************
  Create Cloud Source Repos
*******************************************/
resource "google_sourcerepo_repository" "application_iac" {
  project = module.project.project_id
  name    = "${var.application_name}-iac"
}

/***********************************************
 Cloud Storage Bucket
 ***********************************************/
resource "google_storage_bucket" "terraform_backend" {
  project            = module.project.project_id
  bucket_policy_only = true
  location           = var.default_region
  name               = "tf-state-${var.application_name}"

  labels = {
    project_prefix   = var.project_prefix
    cost_centre      = var.cost_centre
    application_name = var.application_name
  }
}

/***********************************************
 Cloud Build - Master branch triggers
 ***********************************************/

resource "google_cloudbuild_trigger" "master_trigger" {
  project     = module.project.project_id
  description = "${google_sourcerepo_repository.application_iac.name} - terraform apply on push to master."

  trigger_template {
    branch_name = "master"
    repo_name   = google_sourcerepo_repository.application_iac.name
  }

  substitutions = merge({
    _STATE_BUCKET_NAME = google_storage_bucket.terraform_backend.name,

    },
  local.cloudbuild_envs)

  filename = "cloudbuild-tf-apply.yaml"
  depends_on = [
    google_sourcerepo_repository.application_iac,
  ]
}

/***********************************************
 Cloud Build - Non Master branch triggers
 ***********************************************/
resource "google_cloudbuild_trigger" "non_master_trigger" {
  project     = module.project.project_id
  description = "${google_sourcerepo_repository.application_iac.name} - terraform plan on all branches except master."

  trigger_template {
    branch_name = "[^master]"
    repo_name   = google_sourcerepo_repository.application_iac.name
  }

  substitutions = merge({
    _STATE_BUCKET_NAME = google_storage_bucket.terraform_backend.name,

    },
  local.cloudbuild_envs)

  filename = "cloudbuild-tf-plan.yaml"
  depends_on = [
    google_sourcerepo_repository.application_iac,
  ]
}

/******************************************
  KMS Key
 *****************************************/

resource "google_kms_crypto_key" "tf_key" {
  name     = "tf-key"
  key_ring = google_kms_key_ring.tf_keyring.self_link
}

/******************************************
  KMS Keyring
 *****************************************/

resource "google_kms_key_ring" "tf_keyring" {
  project  = module.project.project_id
  name     = "tf-keyring"
  location = var.default_region
}
