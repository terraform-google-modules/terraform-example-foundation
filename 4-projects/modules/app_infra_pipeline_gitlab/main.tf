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
  gl_owner = var.gl_repos != null ? var.gl_repos.owner : ""

  sa_mapping = {
    for k in var.app_infra_repos : k => {
      sa_name   = module.core.terraform_service_accounts_names[k]
      attribute = "attribute.project_path/${local.gl_owner}/${k}"
    }
  }

  common_vars = {
    for k in var.app_infra_repos : k => {
      "GCP_PROJECT_ID"      = module.app_infra_project.project_id
      "GCP_WIF_PROVIDER"    = google_iam_workload_identity_pool_provider.gitlab_provider.name
      "GCP_SERVICE_ACCOUNT" = module.core.terraform_service_accounts[k]
      "TF_STATE_BUCKET"     = module.core.state_buckets[k]
    }
  }

  vars_list = flatten([
    for repo in var.app_infra_repos : [
      for name, value in local.common_vars[repo] : {
        repo  = repo
        name  = name
        value = value
      }
    ]
  ])
}

module "app_infra_project" {
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
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
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

  project_id            = module.app_infra_project.project_id
  default_region        = var.default_region
  app_infra_repos       = var.app_infra_repos
  bucket_prefix         = var.bucket_prefix
  remote_tfstate_bucket = var.remote_tfstate_bucket
}

resource "google_iam_workload_identity_pool" "gitlab_pool" {
  project                   = module.app_infra_project.project_id
  workload_identity_pool_id = "app-infra-pool"
  display_name              = "App Infra GitLab Pool"
  description               = "Workload Identity Pool for App Infra GitLab CI"
}

resource "google_iam_workload_identity_pool_provider" "gitlab_provider" {
  project                            = module.app_infra_project.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.gitlab_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "app-infra-gl-provider"
  display_name                       = "App Infra GitLab Provider"
  attribute_condition                = local.gl_owner != "" ? "assertion.project_path.startsWith('${local.gl_owner}/')" : null
  attribute_mapping = {
    "google.subject"           = "assertion.sub"
    "attribute.sub"            = "assertion.sub"
    "attribute.iss"            = "assertion.iss"
    "attribute.aud"            = "assertion.aud"
    "attribute.project_path"   = "assertion.project_path"
    "attribute.project_id"     = "assertion.project_id"
    "attribute.namespace_id"   = "assertion.namespace_id"
    "attribute.namespace_path" = "assertion.namespace_path"
    "attribute.user_email"     = "assertion.user_email"
    "attribute.ref"            = "assertion.ref"
    "attribute.ref_type"       = "assertion.ref_type"
  }
  oidc {
    allowed_audiences = [var.gitlab_url]
    issuer_uri        = var.gitlab_url
  }
}

resource "google_service_account_iam_member" "wif_sa" {
  for_each           = local.sa_mapping
  service_account_id = each.value.sa_name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.gitlab_pool.name}/${each.value.attribute}"
}

resource "gitlab_project_variable" "variables" {
  for_each = { for v in local.vars_list : "${v.repo}.${v.name}" => v }

  project   = "${local.gl_owner}/${each.value.repo}"
  key       = each.value.name
  value     = each.value.value
  protected = false
  masked    = true
}
