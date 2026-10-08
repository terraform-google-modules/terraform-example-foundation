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
  gh_owner = var.gh_repos != null ? var.gh_repos.owner : ""

  sa_mapping = {
    for k in var.app_infra_repos : k => {
      sa_name   = module.core.terraform_service_accounts_names[k]
      attribute = "attribute.repository/${local.gh_owner}/${k}"
    }
  }

  common_secrets = {
    for k in var.app_infra_repos : k => {
      "PROJECT_ID"            = module.app_infra_project.project_id
      "WIF_PROVIDER_NAME"     = module.gh_oidc.provider_name
      "TF_BACKEND"            = module.core.state_buckets[k]
      "SERVICE_ACCOUNT_EMAIL" = module.core.terraform_service_accounts[k]
    }
  }

  secrets_list = flatten([
    for repo in var.app_infra_repos : [
      for secret_name, secret_val in local.common_secrets[repo] : {
        repo        = repo
        secret_name = secret_name
        value       = secret_val
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

module "gh_oidc" {
  source  = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version = "~> 5.1"

  project_id          = module.app_infra_project.project_id
  pool_id             = "app-infra-pool"
  provider_id         = "app-infra-gh-provider"
  sa_mapping          = local.sa_mapping
  attribute_condition = local.gh_owner != "" ? "assertion.repository_owner=='${local.gh_owner}'" : null
}

resource "github_actions_secret" "secrets" {
  for_each = { for s in local.secrets_list : "${s.repo}.${s.secret_name}" => s }

  repository  = each.value.repo
  secret_name = each.value.secret_name
  value       = each.value.value
}

resource "google_service_account_iam_member" "token_creator" {
  for_each = toset(var.app_infra_repos)

  service_account_id = module.core.terraform_service_accounts_ids[each.key]
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${module.core.terraform_service_accounts[each.key]}"
}
