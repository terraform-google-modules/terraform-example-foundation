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

locals {
  cloudbuild_project_id            = module.app_infra_cloudbuild_project.project_id
  cloudbuild_bucket_name           = "${module.app_infra_cloudbuild_project.project_id}_cloudbuild"
  gar_project_id                   = length(split("/", var.cloud_builder_artifact_repo)) > 1 ? split("/", var.cloud_builder_artifact_repo)[1] : module.app_infra_cloudbuild_project.project_id
  gar_region                       = length(split("/", var.cloud_builder_artifact_repo)) > 3 ? split("/", var.cloud_builder_artifact_repo)[3] : var.default_region
  gar_name                         = length(split("/", var.cloud_builder_artifact_repo)) > 1 ? split("/", var.cloud_builder_artifact_repo)[length(split("/", var.cloud_builder_artifact_repo)) - 1] : "tf-runners"
  first_repo                       = length(var.app_infra_repos) > 0 ? var.app_infra_repos[0] : "bu1-example-app"
  log_buckets                      = { for k, ws in module.tf_workspace : k => split("/", ws.logs_bucket)[length(split("/", ws.logs_bucket)) - 1] }
  confidential_space_image_version = "latest"
  confidential_space_image_tag     = "${var.default_region}-docker.pkg.dev/${module.app_infra_cloudbuild_project.project_id}/tf-runners/confidential_space_image:${local.confidential_space_image_version}"
  cmd_prompt                       = "gcloud builds submit . --tag ${local.confidential_space_image_tag} --project=${module.app_infra_cloudbuild_project.project_id} --service-account=projects/${module.app_infra_cloudbuild_project.project_id}/serviceAccounts/tf-cb-builder-sa@${module.app_infra_cloudbuild_project.project_id}.iam.gserviceaccount.com --gcs-log-dir=gs://${local.log_buckets[local.first_repo]} --worker-pool=${var.cloud_build_private_worker_pool_id} || ( sleep 46 && gcloud builds submit . --tag ${local.confidential_space_image_tag} --project=${module.app_infra_cloudbuild_project.project_id} --service-account=projects/${module.app_infra_cloudbuild_project.project_id}/serviceAccounts/tf-cb-builder-sa@${module.app_infra_cloudbuild_project.project_id}.iam.gserviceaccount.com --gcs-log-dir=gs://${local.log_buckets[local.first_repo]} --worker-pool=${var.cloud_build_private_worker_pool_id})"

  iam_roles_build = [
    "roles/storage.objectAdmin",
    "roles/cloudbuild.builds.builder",
  ]
}

module "app_infra_cloudbuild_project" {
  source = "../../modules/single_project"

  org_id          = var.org_id
  billing_account = var.billing_account
  folder_id       = var.folder_id
  environment     = "common"
  project_budget  = var.project_budget
  project_prefix  = var.project_prefix

  project_deletion_policy = var.project_deletion_policy

  vpc_service_control_attach_enabled = var.enforce_vpcsc ? "true" : "false"
  vpc_service_control_attach_dry_run = !var.enforce_vpcsc ? "true" : "false"
  vpc_service_control_perimeter_name = "accessPolicies/${var.access_context_manager_policy_id}/servicePerimeters/${var.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"

  activate_apis = [
    "cloudbuild.googleapis.com",
    "sourcerepo.googleapis.com",
    "cloudkms.googleapis.com",
    "iam.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "confidentialcomputing.googleapis.com"
  ]
  # Metadata
  project_suffix    = "infra-pipeline"
  application_name  = "app-infra-pipelines"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = "bu1"
}

module "core" {
  source = "../app_infra_core"

  project_id            = module.app_infra_cloudbuild_project.project_id
  default_region        = var.default_region
  app_infra_repos       = var.app_infra_repos
  bucket_prefix         = var.bucket_prefix
  remote_tfstate_bucket = var.remote_tfstate_bucket
}

# Create CSRs
resource "google_sourcerepo_repository" "app_infra_repo" {
  for_each = toset(var.app_infra_repos)

  project = module.app_infra_cloudbuild_project.project_id
  name    = each.value
}

resource "google_sourcerepo_repository" "gcp_policies" {
  project = module.app_infra_cloudbuild_project.project_id
  name    = "gcp-policies"
}

resource "google_storage_bucket" "cloudbuild_bucket" {
  project  = module.app_infra_cloudbuild_project.project_id
  name     = local.cloudbuild_bucket_name
  location = var.default_region

  uniform_bucket_level_access = true
  force_destroy               = true
  versioning {
    enabled = true
  }
}

module "tf_workspace" {
  source  = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_workspace"
  version = "~> 13.0"

  for_each = toset(var.app_infra_repos)

  project_id       = module.app_infra_cloudbuild_project.project_id
  location         = var.default_region
  trigger_location = var.default_region

  create_state_bucket    = false
  state_bucket_self_link = module.core.state_bucket_self_links[each.key]

  log_bucket_name           = "${var.bucket_prefix}-${module.app_infra_cloudbuild_project.project_id}-${each.key}-logs"
  artifacts_bucket_name     = "${var.bucket_prefix}-${module.app_infra_cloudbuild_project.project_id}-${each.key}-artifacts"
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"
  enable_worker_pool        = true
  worker_pool_id            = var.cloud_build_private_worker_pool_id
  tf_repo_uri               = google_sourcerepo_repository.app_infra_repo[each.key].url

  create_cloudbuild_sa = false
  cloudbuild_sa        = module.core.terraform_service_accounts[each.key]

  diff_sa_project       = true
  buckets_force_destroy = true

  substitutions = {
    "_BILLING_ID"                   = var.billing_account
    "_GAR_REGION"                   = local.gar_region
    "_GAR_PROJECT_ID"               = local.gar_project_id
    "_GAR_REPOSITORY"               = local.gar_name
    "_DOCKER_TAG_VERSION_TERRAFORM" = var.terraform_docker_tag_version
  }

  tf_apply_branches = ["development", "nonproduction", "production"]

  depends_on = [
    google_sourcerepo_repository.app_infra_repo,
  ]
}

/***********************************************
  Cloud Build - IAM
 ***********************************************/
resource "google_artifact_registry_repository_iam_member" "terraform_image_iam" {
  provider = google-beta
  for_each = toset(var.app_infra_repos)

  project    = local.gar_project_id
  location   = local.gar_region
  repository = local.gar_name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${module.core.terraform_service_accounts[each.key]}"
}

resource "google_sourcerepo_repository_iam_member" "member" {
  for_each = toset(var.app_infra_repos)

  project    = google_sourcerepo_repository.gcp_policies.project
  repository = google_sourcerepo_repository.gcp_policies.name
  role       = "roles/viewer"
  member     = "serviceAccount:${module.core.terraform_service_accounts[each.key]}"
}

resource "google_project_iam_member" "build_roles" {
  for_each = toset(local.iam_roles_build)

  project = module.app_infra_cloudbuild_project.project_id
  role    = each.key
  member  = "serviceAccount:tf-cb-builder-sa@${module.app_infra_cloudbuild_project.project_id}.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "bucket_admin_binding" {
  count = var.projects_terraform_sa != "" ? 1 : 0

  project = module.app_infra_cloudbuild_project.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${var.projects_terraform_sa}"
}

resource "google_artifact_registry_repository_iam_member" "builder_on_artifact_registry" {
  project    = module.app_infra_cloudbuild_project.project_id
  location   = var.default_region
  repository = module.core.artifact_registry_name
  role       = "roles/artifactregistry.repoAdmin"
  member     = "serviceAccount:${module.app_infra_cloudbuild_project.sa}"
}

resource "google_project_iam_member" "cloudbuild_logging" {
  project = module.app_infra_cloudbuild_project.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${module.app_infra_cloudbuild_project.sa}"
}

resource "google_project_iam_member" "workload_identity_admin" {
  project = module.app_infra_cloudbuild_project.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${module.app_infra_cloudbuild_project.sa}"
}

resource "google_storage_bucket_iam_member" "cloudbuild_storage_read" {
  for_each = toset(var.app_infra_repos)

  bucket = local.log_buckets[each.key]
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.app_infra_cloudbuild_project.sa}"
}

resource "google_storage_bucket_iam_member" "cloudbuild_sa_storage_admin" {
  for_each = toset(var.app_infra_repos)

  bucket = local.log_buckets[each.key]
  role   = "roles/storage.admin"
  member = "serviceAccount:tf-cb-builder-sa@${module.app_infra_cloudbuild_project.project_id}.iam.gserviceaccount.com"
}

resource "time_sleep" "wait_iam_propagation" {
  create_duration = var.iam_propagation_sleep_duration

  depends_on = [
    module.tf_workspace,
    module.app_infra_cloudbuild_project,
    google_project_iam_member.bucket_admin_binding,
    google_storage_bucket_iam_member.cloudbuild_storage_read,
    google_artifact_registry_repository_iam_member.builder_on_artifact_registry,
    google_project_iam_member.cloudbuild_logging,
    google_storage_bucket_iam_member.cloudbuild_sa_storage_admin,
  ]
}

module "build_confidential_space_image" {
  source  = "terraform-google-modules/gcloud/google"
  version = "~> 4.0"

  upgrade           = false
  module_depends_on = [time_sleep.wait_iam_propagation]

  create_cmd_triggers = {
    "tag_version" = local.confidential_space_image_version
    "cmd_prompt"  = local.cmd_prompt
  }

  create_cmd_entrypoint = "bash"
  create_cmd_body       = "${local.cmd_prompt} || ( sleep 45 && ${local.cmd_prompt})"
}
