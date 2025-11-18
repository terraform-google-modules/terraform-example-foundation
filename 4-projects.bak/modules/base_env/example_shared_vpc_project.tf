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

module "shared_vpc_project" {
  source = "../single_project"

  org_id                     = local.org_id
  billing_account            = local.billing_account
  folder_id                  = google_folder.env_business_unit.name
  environment                = var.env
  vpc                        = "svpc"
  shared_vpc_host_project_id = local.shared_vpc_host_project_id
  shared_vpc_subnets         = local.subnets_self_links
  project_budget             = var.project_budget
  project_prefix             = local.project_prefix
  project_deletion_policy    = var.project_deletion_policy

  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  sa_roles = {
    "${var.business_code}-example-app" = [
      "roles/compute.instanceAdmin.v1",
      "roles/iam.serviceAccountUser",
      "roles/iam.serviceAccountAdmin",
    ]
  }

  activate_apis                      = ["accesscontextmanager.googleapis.com"]
  vpc_service_control_attach_enabled = local.enforce_vpcsc ? "true" : "false"
  vpc_service_control_attach_dry_run = !local.enforce_vpcsc ? "true" : "false"
  vpc_service_control_perimeter_name = "accessPolicies/${local.access_context_manager_policy_id}/servicePerimeters/${local.perimeter_name}"
  vpc_service_control_sleep_duration = "60s"

  # Metadata
  project_suffix    = "sample-svpc"
  application_name  = "${var.business_code}-sample-application"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}
