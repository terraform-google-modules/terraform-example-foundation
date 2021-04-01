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

module "app_infra_bu1_development" {
  source                  = "../../../5-app-infra/business_unit_1/development"
  parent_folder           = var.parent_folder
  org_id                  = var.org_id
  project_service_account = var.terraform_service_account
  folder_prefix           = var.folder_prefix
  instance_region         = "us-west1"
}

module "app_infra_bu1_nonproduction" {
  source                  = "../../../5-app-infra/business_unit_1/non-production"
  parent_folder           = var.parent_folder
  org_id                  = var.org_id
  project_service_account = var.terraform_service_account
  folder_prefix           = var.folder_prefix
  instance_region         = "us-west1"
}

module "app_infra_bu1_production" {
  source                  = "../../../5-app-infra/business_unit_1/production"
  parent_folder           = var.parent_folder
  org_id                  = var.org_id
  project_service_account = var.terraform_service_account
  folder_prefix           = var.folder_prefix
  instance_region         = "us-west1"
}
