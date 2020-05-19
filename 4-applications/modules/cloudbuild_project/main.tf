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
  application_projects = data.google_projects.application_projects.projects.*.project_id

  network_project_nonprod = data.google_projects.network_projects_nonprod.projects[0].project_id
  network_project_prod    = data.google_projects.network_projects_prod.projects[0].project_id

  project_id_env_map = {
    for id, project in data.google_project.application_project :
    id
    => element([for key, value in project.labels : value if key == "environment"], 0)
  }

  cloudbuild_env_variables_maps = [
    for project_id, env in local.project_id_env_map :
    {
      "_SA_EMAIL_${upper(env)}"           = google_service_account.children[project_id].email
      "_APP_PROJECT_${upper(env)}"        = project_id
      "_NETWORK_PROJECT_ID_${upper(env)}" = env == "nonprod" ? local.network_project_nonprod : local.network_project_prod
    }
  ]

  cloudbuild_envs = zipmap(
    flatten([for index, value in local.cloudbuild_env_variables_maps : [for k, v in value : k]]),
    flatten([for index, value in local.cloudbuild_env_variables_maps : [for k, v in value : v]])
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
  KMS Keyring
 *****************************************/

resource "google_kms_key_ring" "tf_keyring" {
  project  = module.project.project_id
  name     = "tf-keyring"
  location = var.default_region
}
