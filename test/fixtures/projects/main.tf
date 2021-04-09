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

module "bu1_shared" {
  source                    = "../../../4-projects/business_unit_1/shared"
  terraform_service_account = var.terraform_service_account
  default_region            = "us-west1"
  org_id                    = var.org_id
  billing_account           = var.billing_account
  parent_folder             = var.parent_folder
  project_prefix            = var.project_prefix
}

module "projects_bu1_dev" {
  source                           = "../../../4-projects/business_unit_1/development"
  terraform_service_account        = var.terraform_service_account
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.dev_restricted_service_perimeter_name
  project_prefix                   = var.project_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = module.bu1_shared.cloudbuild_sa
}

module "projects_bu1_nonprod" {
  source                           = "../../../4-projects/business_unit_1/non-production"
  terraform_service_account        = var.terraform_service_account
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.nonprod_restricted_service_perimeter_name
  project_prefix                   = var.project_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = module.bu1_shared.cloudbuild_sa
}


module "projects_bu1_prod" {
  source                           = "../../../4-projects/business_unit_1/production"
  terraform_service_account        = var.terraform_service_account
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.prod_restricted_service_perimeter_name
  project_prefix                   = var.project_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = module.bu1_shared.cloudbuild_sa
}

module "bu2_shared" {
  source                    = "../../../4-projects/business_unit_2/shared"
  terraform_service_account = var.terraform_service_account
  default_region            = "us-west1"
  org_id                    = var.org_id
  billing_account           = var.billing_account
  parent_folder             = var.parent_folder
  project_prefix            = var.project_prefix
}

module "projects_bu2_dev" {
  source                           = "../../../4-projects/business_unit_2/development"
  terraform_service_account        = var.terraform_service_account
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.dev_restricted_service_perimeter_name
  peering_module_depends_on        = [module.projects_bu1_dev.peering_complete]
  project_prefix                   = var.project_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = module.bu2_shared.cloudbuild_sa
}

module "projects_bu2_nonprod" {
  source                           = "../../../4-projects/business_unit_2/non-production"
  terraform_service_account        = var.terraform_service_account
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.nonprod_restricted_service_perimeter_name
  peering_module_depends_on        = [module.projects_bu1_nonprod.peering_complete]
  project_prefix                   = var.project_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = module.bu2_shared.cloudbuild_sa
}


module "projects_bu2_prod" {
  source                           = "../../../4-projects/business_unit_2/production"
  terraform_service_account        = var.terraform_service_account
  org_id                           = var.org_id
  billing_account                  = var.billing_account
  access_context_manager_policy_id = var.policy_id
  parent_folder                    = var.parent_folder
  perimeter_name                   = var.prod_restricted_service_perimeter_name
  peering_module_depends_on        = [module.projects_bu1_prod.peering_complete]
  project_prefix                   = var.project_prefix
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  app_infra_pipeline_cloudbuild_sa = module.bu2_shared.cloudbuild_sa
}
