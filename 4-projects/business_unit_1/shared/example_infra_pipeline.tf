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

locals {
  repo_names              = ["bu1-example-app"]
  confidential_repo_names = ["bu1-confidential-space"]

  cmd_prompt = "gcloud builds submit confidential-space-attestation/. --tag ${local.binary_auth_image_tag} --project=${module.confidential_space_cloudbuild_project[0].project_id}  --service-account=${google_service_account.workload_sa.email} --gcs-log-dir=${module.confidential_space_infra_pipelines[0].log_buckets} --worker-pool=${module.confidential_space_infra_pipelines[0].worker_pool_id}  || ( sleep 45 && gcloud builds submit --tag ${local.binary_auth_image_tag} --project=${module.confidential_space_cloudbuild_project[0].project_id} --service-account=${google_service_account.workload_sa.email} --gcs-log-dir=${module.confidential_space_infra_pipelines[0].log_buckets} --worker-pool=${module.confidential_space_infra_pipelines[0].worker_pool_id}  )"

  binary_auth_image_version = "latest"
  binary_auth_image_tag     = "${var.artifact_registry_location}-docker.pkg.dev/${module.confidential_space_cloudbuild_project[0].project_id}/${google_artifact_registry_repository.ar_confidential_space.repository_id}/workload-confidential-space:${local.binary_auth_image_version}"
}

module "app_infra_cloudbuild_project" {
  source = "../../modules/single_project"
  count  = local.enable_cloudbuild_deploy ? 1 : 0

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.common_folder_name
  environment     = "common"
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  project_deletion_policy = var.project_deletion_policy

  activate_apis = [
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  # Metadata
  project_suffix    = "infra-pipeline"
  application_name  = "app-infra-pipelines"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu1"
}

module "infra_pipelines" {
  source = "../../modules/infra_pipelines"
  count  = local.enable_cloudbuild_deploy ? 1 : 0

  org_id                      = local.org_id
  cloudbuild_project_id       = module.app_infra_cloudbuild_project[0].project_id
  cloud_builder_artifact_repo = local.cloud_builder_artifact_repo
  remote_tfstate_bucket       = local.projects_remote_bucket_tfstate
  billing_account             = local.billing_account
  default_region              = var.default_region
  app_infra_repos             = local.repo_names
  private_worker_pool_id      = local.cloud_build_private_worker_pool_id
}

resource "google_service_account" "workload_sa" {
  account_id   = "confidential-space-workload-sa"
  display_name = "Workload Service Account for confidential space"
  project      = module.confidential_space_cloudbuild_project[0].project_id
}

resource "google_artifact_registry_repository" "ar_confidential_space" {
  repository_id = "ar-confidential-space"
  format        = "DOCKER"
  location      = var.default_region
  project       = module.app_infra_cloudbuild_project[0].project_id
}

resource "google_artifact_registry_repository_iam_member" "artifact_registry_reader" {
  repository = google_artifact_registry_repository.ar_confidential_space.id
  location   = google_artifact_registry_repository.ar_confidential_space.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.workload_sa.email}"
}

module "confidential_space_cloudbuild_project" {
  source = "../../modules/single_project"
  count  = local.enable_cloudbuild_deploy ? 1 : 0

  org_id          = local.org_id
  billing_account = local.billing_account
  folder_id       = local.common_folder_name
  environment     = "common"
  project_budget  = var.project_budget
  project_prefix  = local.project_prefix

  project_deletion_policy = var.project_deletion_policy

  activate_apis = [
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  # Metadata
  project_suffix    = "confidential-space"
  application_name  = "app-confidential-space"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu1"
}

module "confidential_space_infra_pipelines" {
  source = "../../modules/infra_pipelines"
  count  = local.enable_cloudbuild_deploy ? 1 : 0

  org_id                      = local.org_id
  cloudbuild_project_id       = module.confidential_space_cloudbuild_project[0].project_id
  cloud_builder_artifact_repo = local.cloud_builder_artifact_repo
  remote_tfstate_bucket       = local.projects_remote_bucket_tfstate
  billing_account             = local.billing_account
  default_region              = var.default_region
  app_infra_repos             = local.confidential_repo_names
  private_worker_pool_id      = local.cloud_build_private_worker_pool_id
}

/**
 * When Jenkins CI/CD is used for deployment this resource
 * is created to terraform validation works.
 * Without this resource, this module creates zero resources
 * and it breaks terraform validation throwing the error below:
 * ERROR: [Terraform plan json does not contain resource_changes key]
 */
resource "null_resource" "jenkins_cicd" {
  count = !local.enable_cloudbuild_deploy ? 1 : 0
}

