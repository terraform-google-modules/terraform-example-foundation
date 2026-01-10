/**
 * Copyright 2022 Google LLC
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

// These values are retrieved from the saved terraform state of the execution
// of step 0-bootstrap using the terraform_remote_state data source.
// These values can be overridden here if needed.
// Some values, like org_id, parent_folder, and parent, must be consistent in all steps.
locals {
  org_id                                        = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
  parent_folder                                 = data.terraform_remote_state.bootstrap.outputs.common_config.parent_folder
  parent                                        = data.terraform_remote_state.bootstrap.outputs.common_config.parent_id
  billing_account                               = data.terraform_remote_state.bootstrap.outputs.common_config.billing_account
  default_region                                = data.terraform_remote_state.bootstrap.outputs.common_config.default_region
  project_prefix                                = data.terraform_remote_state.bootstrap.outputs.common_config.project_prefix
  folder_prefix                                 = data.terraform_remote_state.bootstrap.outputs.common_config.folder_prefix
  networks_step_terraform_service_account_email = data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email
  org_step_terraform_service_account_email      = data.terraform_remote_state.bootstrap.outputs.organization_step_terraform_service_account_email
  bootstrap_folder_name                         = data.terraform_remote_state.bootstrap.outputs.common_config.bootstrap_folder_name
  cloud_build_private_worker_pool_id            = try(data.terraform_remote_state.bootstrap.outputs.cloud_build_private_worker_pool_id, "")
  required_groups                               = data.terraform_remote_state.bootstrap.outputs.required_groups
  organization_service_account                  = data.terraform_remote_state.bootstrap.outputs.organization_step_terraform_service_account_email
  networks_service_account                      = data.terraform_remote_state.bootstrap.outputs.networks_step_terraform_service_account_email
  projects_service_account                      = data.terraform_remote_state.bootstrap.outputs.projects_step_terraform_service_account_email
  environment_service_account                   = data.terraform_remote_state.bootstrap.outputs.environment_step_terraform_service_account_email
  cloud_builder_artifact_repo                   = try(data.terraform_remote_state.bootstrap.outputs.cloud_builder_artifact_repo, "")
  enable_cloudbuild_deploy                      = local.cloud_builder_artifact_repo != ""
  cloudbuild_project_number                     = data.terraform_remote_state.bootstrap.outputs.cicd_project_number
  seed_project_id                               = data.terraform_remote_state.bootstrap.outputs.seed_project_id
  seed_project_number                           = data.terraform_remote_state.bootstrap.outputs.seed_project_number
  parent_id                                     = data.terraform_remote_state.bootstrap.outputs.parent_id
  projects_gcs_bucket_tfstate                   = data.terraform_remote_state.bootstrap.outputs.projects_gcs_bucket_tfstate
  peering_projects_numbers                      = compact([for s in data.terraform_remote_state.projects_env : try(s.outputs.peering_project_number, null)])
  shared_vpc_project_numbers                    = compact([for s in data.terraform_remote_state.projects_env : try(s.outputs.shared_vpc_project_number, null)])
  app_infra_project_id                          = try(data.terraform_remote_state.projects_app_infra[0].outputs.cloudbuild_project_id, null)
  app_infra_project_number                      = try(data.terraform_remote_state.projects_app_infra[0].outputs.cloudbuild_project_number, null)

  app_infra_pipeline_identity = (
    local.app_infra_project_number != ""
    ? "serviceAccount:${local.app_infra_project_number}@cloudbuild.gserviceaccount.com"
    : null
  )

  app_infra_pipeline_source_projects = (
    local.app_infra_project_number != ""
    ? ["projects/${local.app_infra_project_number}"]
    : []
  )

  app_infra_cicd_identity = (
    local.app_infra_project_id != ""
    ? "serviceAccount:sa-tf-cb-bu1-example-app@${local.app_infra_project_id}.iam.gserviceaccount.com"
    : null
  )

  app_infra_targets = distinct(concat(
    [for n in local.shared_vpc_project_numbers : "projects/${n}"],
    [for n in local.peering_projects_numbers : "projects/${n}"]
  ))
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"

  config = {
    bucket = var.remote_state_bucket
    prefix = "terraform/bootstrap/state"
  }
}

data "terraform_remote_state" "projects_env" {
  backend = "gcs"

  for_each = (var.required_egress_rules_app_infra_dry_run && var.required_ingress_rules_app_infra_dry_run) || (var.required_egress_rules_app_infra && var.required_ingress_rules_app_infra) ? var.envs : {}

  config = {
    bucket = local.projects_gcs_bucket_tfstate
    prefix = "terraform/projects/business_unit_1/${each.key}"
  }
}

data "terraform_remote_state" "projects_app_infra" {
  backend = "gcs"

  count = (var.required_egress_rules_app_infra_dry_run && var.required_ingress_rules_app_infra_dry_run) || (var.required_egress_rules_app_infra && var.required_ingress_rules_app_infra) ? 1 : 0

  config = {
    bucket = local.projects_gcs_bucket_tfstate
    prefix = "terraform/projects/business_unit_1/shared"
  }
}
