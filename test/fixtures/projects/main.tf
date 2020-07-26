/**
 * Copyright 2020 Google LLC
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

module "projects_bu1_dev" {
  source                    = "../../../4-projects/business_unit_1/dev"
  terraform_service_account = var.terraform_sa_email
  org_id                    = var.org_id
  billing_account           = var.billing_account
  policy_id                 = var.policy_id
  parent_folder             = var.parent_folder
  perimeter_name            = var.dev_restricted_service_perimeter_name
}

module "projects_bu1_nonprod" {
  source                    = "../../../4-projects/business_unit_1/nonprod"
  terraform_service_account = var.terraform_sa_email
  org_id                    = var.org_id
  billing_account           = var.billing_account
  policy_id                 = var.policy_id
  parent_folder             = var.parent_folder
  perimeter_name            = var.nonprod_restricted_service_perimeter_name
}


module "projects_bu1_prod" {
  source                    = "../../../4-projects/business_unit_1/prod"
  terraform_service_account = var.terraform_sa_email
  org_id                    = var.org_id
  billing_account           = var.billing_account
  policy_id                 = var.policy_id
  parent_folder             = var.parent_folder
  perimeter_name            = var.prod_restricted_service_perimeter_name
}

module "projects_bu2_dev" {
  source                    = "../../../4-projects/business_unit_2/dev"
  terraform_service_account = var.terraform_sa_email
  org_id                    = var.org_id
  billing_account           = var.billing_account
  policy_id                 = var.policy_id
  parent_folder             = var.parent_folder
  perimeter_name            = var.dev_restricted_service_perimeter_name
}

module "projects_bu2_nonprod" {
  source                    = "../../../4-projects/business_unit_2/nonprod"
  terraform_service_account = var.terraform_sa_email
  org_id                    = var.org_id
  billing_account           = var.billing_account
  policy_id                 = var.policy_id
  parent_folder             = var.parent_folder
  perimeter_name            = var.nonprod_restricted_service_perimeter_name
}


module "projects_bu2_prod" {
  source                    = "../../../4-projects/business_unit_2/prod"
  terraform_service_account = var.terraform_sa_email
  org_id                    = var.org_id
  billing_account           = var.billing_account
  policy_id                 = var.policy_id
  parent_folder             = var.parent_folder
  perimeter_name            = var.prod_restricted_service_perimeter_name
}
