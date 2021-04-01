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

module "development" {
  source                           = "../../../3-networks/envs/development"
  org_id                           = var.org_id
  access_context_manager_policy_id = var.policy_id
  default_region2                  = "us-central1"
  default_region1                  = "us-west1"
  domain                           = var.domain
  terraform_service_account        = var.terraform_service_account
  parent_folder                    = var.parent_folder
  enable_hub_and_spoke             = var.enable_hub_and_spoke
}

module "non-production" {
  source                           = "../../../3-networks/envs/non-production"
  org_id                           = var.org_id
  access_context_manager_policy_id = var.policy_id
  default_region2                  = "us-central1"
  default_region1                  = "us-west1"
  domain                           = var.domain
  terraform_service_account        = var.terraform_service_account
  parent_folder                    = var.parent_folder
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  depends_on                       = [module.development]
}

module "production" {
  source                           = "../../../3-networks/envs/production"
  org_id                           = var.org_id
  access_context_manager_policy_id = var.policy_id
  default_region2                  = "us-central1"
  default_region1                  = "us-west1"
  domain                           = var.domain
  terraform_service_account        = var.terraform_service_account
  parent_folder                    = var.parent_folder
  enable_hub_and_spoke             = var.enable_hub_and_spoke
  depends_on                       = [module.non-production]
}
