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
  cloudbuild_bucket_name = "${var.cloudbuild_project_id}_cloudbuild"
  workspace_sa_email     = { for k, v in module.tf_workspace : k => element(split("/", v.cloudbuild_sa), length(split("/", v.cloudbuild_sa)) - 1) }
  gar_project_id         = split("/", var.cloud_builder_artifact_repo)[1]
  gar_region             = split("/", var.cloud_builder_artifact_repo)[3]
  gar_name               = split("/", var.cloud_builder_artifact_repo)[length(split("/", var.cloud_builder_artifact_repo)) - 1]
  created_repos          = local.use_csr ? { for k, v in google_sourcerepo_repository.app_infra_repo : k => v.name } : module.cloudbuild_repositories[0].cloud_build_repositories_2nd_gen_repositories
  artifact_buckets       = { for k, ws in module.tf_workspace : k => split("/", ws.artifacts_bucket)[length(split("/", ws.artifacts_bucket)) - 1] }
  state_buckets          = { for k, ws in module.tf_workspace : k => split("/", ws.state_bucket)[length(split("/", ws.state_bucket)) - 1] }
  log_buckets            = { for k, ws in module.tf_workspace : k => split("/", ws.logs_bucket)[length(split("/", ws.logs_bucket)) - 1] }
  plan_triggers_id       = [for ws in module.tf_workspace : ws.cloudbuild_plan_trigger_id]
  apply_triggers_id      = [for ws in module.tf_workspace : ws.cloudbuild_apply_trigger_id]
  use_csr                = var.cloudbuildv2_repository_config.repo_type == "CSR"
  csr_repos              = local.use_csr ? [for k, v in var.cloudbuildv2_repository_config.repositories : v.repository_name] : []
}

# Create CSRs if the user did not specify a Cloud Build Repository (2nd Gen)
resource "google_sourcerepo_repository" "app_infra_repo" {
  for_each = toset(local.csr_repos)

  project = var.cloudbuild_project_id
  name    = each.value.repository_name
}

resource "google_sourcerepo_repository" "gcp_policies" {
  count = local.use_csr ? 1 : 0

  project = var.cloudbuild_project_id
  name    = "gcp-policies"
}

resource "google_storage_bucket" "cloudbuild_bucket" {
  project  = var.cloudbuild_project_id
  name     = local.cloudbuild_bucket_name
  location = var.default_region

  uniform_bucket_level_access = true
  force_destroy               = true
  versioning {
    enabled = true
  }
}

module "cloudbuild_repositories" {
  count  = local.use_csr ? 0 : 1
  source = "git::https://github.com/terraform-google-modules/terraform-google-bootstrap.git//modules/cloudbuild_repo_connection?ref=f79bbc53f0593882e552ee0e1ca4019a4db88ac7"

  project_id = var.cloudbuild_project_id

  credential_config = {
    credential_type                   = var.cloudbuildv2_repository_config.repo_type
    gitlab_authorizer_credential      = var.cloudbuildv2_repository_config.gitlab_authorizer_credential
    gitlab_read_authorizer_credential = var.cloudbuildv2_repository_config.gitlab_read_authorizer_credential
    github_pat                        = var.cloudbuildv2_repository_config.github_pat
    github_app_id                     = var.cloudbuildv2_repository_config.github_app_id
  }
  cloud_build_repositories = var.cloudbuildv2_repository_config.repositories
}

module "tf_workspace" {
  source = "git::https://github.com/terraform-google-modules/terraform-google-bootstrap.git//modules/tf_cloudbuild_workspace?ref=f79bbc53f0593882e552ee0e1ca4019a4db88ac7"
  # version  = "~> 8.0"
  for_each = var.cloudbuildv2_repository_config.repositories

  project_id = var.cloudbuild_project_id
  location   = var.default_region

  # using bucket custom names for compliance with bucket naming conventions
  create_state_bucket       = true
  create_state_bucket_name  = "${var.bucket_prefix}-${var.cloudbuild_project_id}-${each.value.repository_name}-state"
  log_bucket_name           = "${var.bucket_prefix}-${var.cloudbuild_project_id}-${each.value.repository_name}-logs"
  artifacts_bucket_name     = "${var.bucket_prefix}-${var.cloudbuild_project_id}-${each.value.repository_name}-artifacts"
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"
  enable_worker_pool        = true
  worker_pool_id            = var.private_worker_pool_id
  create_cloudbuild_sa      = true
  create_cloudbuild_sa_name = "sa-tf-cb-${each.value.repository_name}"
  diff_sa_project           = true
  buckets_force_destroy     = true
  tf_repo_uri               = local.use_csr ? google_sourcerepo_repository.app_infra_repo[each.key].url : module.cloudbuild_repositories[0].cloud_build_repositories_2nd_gen_repositories[each.key].id
  tf_repo_type              = local.use_csr ? "CLOUD_SOURCE_REPOSITORIES" : "CLOUDBUILD_V2_REPOSITORY"
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
  trigger_location = var.default_region
}

/***********************************************
  Cloud Build - IAM
 ***********************************************/

resource "google_artifact_registry_repository_iam_member" "terraform-image-iam" {
  provider = google-beta
  for_each = var.cloudbuildv2_repository_config.repositories

  project    = local.gar_project_id
  location   = local.gar_region
  repository = local.gar_name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

resource "google_storage_bucket_iam_member" "tf_state" {
  for_each = var.cloudbuildv2_repository_config.repositories

  bucket = var.remote_tfstate_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

// Required by gcloud beta terraform vet
resource "google_organization_iam_member" "browser" {
  for_each = var.cloudbuildv2_repository_config.repositories

  org_id = var.org_id
  role   = "roles/browser"
  member = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

resource "google_sourcerepo_repository_iam_member" "member" {
  for_each = toset(local.csr_repos)

  project    = google_sourcerepo_repository.gcp_policies[0].project
  repository = google_sourcerepo_repository.gcp_policies[0].name
  role       = "roles/viewer"
  member     = "serviceAccount:${local.workspace_sa_email[each.value.repository_name]}"
}
