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
  source                     = "../../../2-environments/envs/development"
  org_id                     = var.org_id
  billing_account            = var.billing_account
  monitoring_workspace_users = var.group_email
  parent_folder              = var.parent_folder
  terraform_service_account  = var.terraform_service_account
  project_prefix             = var.project_prefix
}

module "non-production" {
  source                     = "../../../2-environments/envs/non-production"
  org_id                     = var.org_id
  billing_account            = var.billing_account
  monitoring_workspace_users = var.group_email
  parent_folder              = var.parent_folder
  terraform_service_account  = var.terraform_service_account
  project_prefix             = var.project_prefix
}

module "production" {
  source                     = "../../../2-environments/envs/production"
  org_id                     = var.org_id
  billing_account            = var.billing_account
  monitoring_workspace_users = var.group_email
  parent_folder              = var.parent_folder
  terraform_service_account  = var.terraform_service_account
  project_prefix             = var.project_prefix
}
