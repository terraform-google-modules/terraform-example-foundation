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
  created_csrs           = toset([for repo in google_sourcerepo_repository.app_infra_repo : repo.name])
  artifact_buckets       = { for k, ws in module.tf_workspace : k => split("/", ws.artifacts_bucket)[length(split("/", ws.artifacts_bucket)) - 1] }
  state_buckets          = { for k, ws in module.tf_workspace : k => split("/", ws.state_bucket)[length(split("/", ws.state_bucket)) - 1] }
  log_buckets            = { for k, ws in module.tf_workspace : k => split("/", ws.logs_bucket)[length(split("/", ws.logs_bucket)) - 1] }
  plan_triggers_id       = [for ws in module.tf_workspace : ws.cloudbuild_plan_trigger_id]
  apply_triggers_id      = [for ws in module.tf_workspace : ws.cloudbuild_apply_trigger_id]
}

# Create CSRs
resource "google_sourcerepo_repository" "app_infra_repo" {
  for_each = toset(var.app_infra_repos)

  project = var.cloudbuild_project_id
  name    = each.value
}

resource "google_sourcerepo_repository" "gcp_policies" {
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

module "tf_workspace" {
  source   = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_workspace"
  version  = "~> 6.4"
  for_each = toset(var.app_infra_repos)

  project_id = var.cloudbuild_project_id
  location   = var.default_region

  # using bucket custom names for compliance with bucket naming conventions
  create_state_bucket       = true
  create_state_bucket_name  = "${var.bucket_prefix}-${var.cloudbuild_project_id}-${each.key}-state"
  log_bucket_name           = "${var.bucket_prefix}-${var.cloudbuild_project_id}-${each.key}-logs"
  artifacts_bucket_name     = "${var.bucket_prefix}-${var.cloudbuild_project_id}-${each.key}-artifacts"
  cloudbuild_plan_filename  = "cloudbuild-tf-plan.yaml"
  cloudbuild_apply_filename = "cloudbuild-tf-apply.yaml"
  enable_worker_pool        = true
  worker_pool_id            = var.private_worker_pool_id
  tf_repo_uri               = google_sourcerepo_repository.app_infra_repo[each.key].url
  create_cloudbuild_sa      = true
  create_cloudbuild_sa_name = "sa-tf-cb-${each.key}"
  diff_sa_project           = true
  buckets_force_destroy     = true

  substitutions = {
    "_BILLING_ID"                   = var.billing_account
    "_GAR_REGION"                   = local.gar_region
    "_GAR_PROJECT_ID"               = local.gar_project_id
    "_GAR_REPOSITORY"               = local.gar_name
    "_DOCKER_TAG_VERSION_TERRAFORM" = var.terraform_docker_tag_version
  }

  tf_apply_branches = ["development", "non\\-production", "production"]

  depends_on = [
    google_sourcerepo_repository.app_infra_repo,
  ]

}

/***********************************************
  Cloud Build - IAM
 ***********************************************/

resource "google_artifact_registry_repository_iam_member" "terraform-image-iam" {
  provider = google-beta
  for_each = toset(var.app_infra_repos)

  project    = local.gar_project_id
  location   = local.gar_region
  repository = local.gar_name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

resource "google_storage_bucket_iam_member" "tf_state" {
  for_each = toset(var.app_infra_repos)

  bucket = var.remote_tfstate_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

// Required by gcloud beta terraform vet
resource "google_organization_iam_member" "browser" {
  for_each = toset(var.app_infra_repos)

  org_id = var.org_id
  role   = "roles/browser"
  member = "serviceAccount:${local.workspace_sa_email[each.key]}"
}

resource "google_sourcerepo_repository_iam_member" "member" {
  for_each = toset(var.app_infra_repos)

  project    = google_sourcerepo_repository.gcp_policies.project
  repository = google_sourcerepo_repository.gcp_policies.name
  role       = "roles/viewer"
  member     = "serviceAccount:${local.workspace_sa_email[each.key]}"
}
