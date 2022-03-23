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

module "base_env" {
  source                           = "../../modules/base_env"

  environment_code                 = "n"
  env                              = "non-production"
  org_id                           = var.org_id
  access_context_manager_policy_id = var.access_context_manager_policy_id
  terraform_service_account        = var.terraform_service_account
  default_region1                  = var.default_region1
  default_region2                  = var.default_region2
  domain                           = var.domain
  parent_folder                    = var.parent_folder
}
