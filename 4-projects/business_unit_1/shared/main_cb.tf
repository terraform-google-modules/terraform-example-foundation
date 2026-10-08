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

module "app_infra_pipeline" {
  source = "../../modules/app_infra_pipeline_cb"

  org_id                             = local.org_id
  billing_account                    = local.billing_account
  folder_id                          = local.common_folder_name
  project_prefix                     = local.project_prefix
  default_region                     = var.default_region
  app_infra_repos                    = local.repo_names
  remote_tfstate_bucket              = local.projects_remote_bucket_tfstate
  cloud_build_private_worker_pool_id = local.cloud_build_private_worker_pool_id
  cloud_builder_artifact_repo        = local.cloud_builder_artifact_repo
  enforce_vpcsc                      = local.enforce_vpcsc
  access_context_manager_policy_id   = local.access_context_manager_policy_id
  perimeter_name                     = local.perimeter_name
  project_budget                     = var.project_budget
  project_deletion_policy            = var.project_deletion_policy
  iam_propagation_sleep_duration     = var.iam_propagation_sleep_duration
  projects_terraform_sa              = local.projects_terraform_sa
  bucket_prefix                      = var.bucket_prefix
  terraform_docker_tag_version       = var.terraform_docker_tag_version
}
