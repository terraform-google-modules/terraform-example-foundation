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

module "base_shared_vpc_project" {
  source = "../single_project"

  org_id                              = local.org_id
  billing_account                     = local.billing_account
  folder_id                           = google_folder.env_business_unit.name
  environment                         = var.env
  vpc                                 = "base"
  shared_vpc_host_project_id          = local.base_host_project_id
  shared_vpc_subnets                  = local.base_subnets_self_links
  project_budget                      = var.project_budget
  project_prefix                      = local.project_prefix
  enable_cloudbuild_deploy            = local.enable_cloudbuild_deploy
  app_infra_pipeline_service_accounts = local.app_infra_pipeline_service_accounts

  // The roles defined in "sa_roles" will be used to grant the necessary permissions
  // to deploy the resources, a Compute Engine instance for each environment, defined
  // in 5-app-infra step (5-app-infra/modules/env_base/main.tf).
  // The roles are grouped by the repository name ("${var.business_code}-example-app") used to create the Cloud Build workspace
  // (https://github.com/terraform-google-modules/terraform-google-bootstrap/tree/master/modules/tf_cloudbuild_workspace)
  // in the 4-projects shared environment of each business unit.
  // the repository name is the same key used for the app_infra_pipeline_service_accounts map and the
  // roles will be granted to the service account with the same key.
  sa_roles = {
    "${var.business_code}-example-app" = [
      "roles/compute.instanceAdmin.v1",
      "roles/iam.serviceAccountAdmin",
      "roles/iam.serviceAccountUser",
    ]
  }

  activate_apis = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]

  # Metadata
  project_suffix    = "sample-base"
  application_name  = "${var.business_code}-sample-application"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = var.business_code
}


