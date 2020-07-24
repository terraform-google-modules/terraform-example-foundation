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

locals {
  prefix         = "${var.env_code}_shared_${var.vpc_type}"
  perimeter_name = "sp_${local.prefix}_default_perimeter_1234"
}

module "restricted_shared_vpc_project" {
  source                      = "../../modules/single_project"
  impersonate_service_account = var.terraform_service_account
  org_id                      = var.org_id
  billing_account             = var.billing_account
  folder_id                   = var.parent_folder
  skip_gcloud_download        = var.skip_gcloud_download
  environment                 = local.env
  env_code                    = var.env_code
  vpc_type                    = "restricted"

  activate_apis                      = ["accesscontextmanager.googleapis.com"]
  vpc_service_control_attach_enabled = "true"
  vpc_service_control_perimeter_name = "accessPolicies/${var.policy_id}/servicePerimeters/${local.perimeter_name}"

  # Metadata
  project_prefix    = "prj-${local.business_code}-${var.env_code}-sample"
  application_name  = "${local.business_code}-restricted-sample-single"
  billing_code      = "1234"
  primary_contact   = "example@example.com"
  secondary_contact = "example2@example.com"
  business_code     = local.business_code
}
