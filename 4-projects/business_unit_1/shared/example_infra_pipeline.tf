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
  repo_names                       = ["bu1-example-app"]
  cmd_prompt                       = "gcloud builds submit . --tag ${local.confidential_space_image_tag} --project=${module.app_infra_cloudbuild_project[0].project_id}  --service-account=projects/${module.app_infra_cloudbuild_project[0].project_id}/serviceAccounts/${module.app_infra_cloudbuild_project[0].sa} --gcs-log-dir=gs://bkt-${module.app_infra_cloudbuild_project[0].project_id}-bu1-example-app-logs --worker-pool=${local.cloud_build_private_worker_pool_id}  || ( sleep 45 && gcloud builds submit --tag ${local.confidential_space_image_tag} --project=${module.app_infra_cloudbuild_project[0].project_id} --service-account=projects/${module.app_infra_cloudbuild_project[0].project_id}/serviceAccounts/${module.app_infra_cloudbuild_project[0].sa} --gcs-log-dir=gs://bkt-${module.app_infra_cloudbuild_project[0].project_id}-bu1-example-app-logs --worker-pool=${local.cloud_build_private_worker_pool_id}  )"
  confidential_space_image_version = "latest"
  confidential_space_image_tag     = "${var.artifact_registry_location}-docker.pkg.dev/${local.cloudbuild_project_id}/tf-runners/confidential_space_image:${local.confidential_space_image_version}"
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

resource "google_storage_bucket_iam_member" "allow_build_sa_to_read" {
  bucket = "bkt-${module.app_infra_cloudbuild_project[0].project_id}-bu1-example-app-logs"
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.app_infra_cloudbuild_project[0].sa}"
}

resource "google_artifact_registry_repository_iam_member" "builder_on_artifact_registry" {
  project    = local.cloudbuild_project_id
  location   = var.artifact_registry_location
  repository = "tf-runners"
  role       = "roles/artifactregistry.repoAdmin"
  member     = "serviceAccount:${module.app_infra_cloudbuild_project[0].sa}"
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

resource "time_sleep" "wait_iam_propagation" {
  create_duration = "60s"

  depends_on = [
    module.infra_pipelines,
    module.app_infra_cloudbuild_project,
    google_storage_bucket_iam_member.allow_build_sa_to_read,
    google_artifact_registry_repository_iam_member.builder_on_artifact_registry
  ]
}

module "build_confidential_space_image" {
  source            = "terraform-google-modules/gcloud/google"
  version           = "~> 3.5"
  upgrade           = false
  module_depends_on = [time_sleep.wait_iam_propagation]

  create_cmd_triggers = {
    "tag_version" = local.confidential_space_image_version
    "cmd_prompt"  = local.cmd_prompt
  }

  create_cmd_entrypoint = "bash"
  create_cmd_body       = "${local.cmd_prompt} || ( sleep 45 && ${local.cmd_prompt})"
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


