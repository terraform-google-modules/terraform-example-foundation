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

module "shared" {
  source                            = "../../../3-networks/envs/shared"
  default_region1                   = "us-central1"
  default_region2                   = "us-west1"
  domain                            = var.domain
  access_context_manager_policy_id  = var.policy_id
  target_name_server_addresses      = ["192.168.0.1", "192.168.0.2"]
  terraform_service_account         = var.terraform_service_account
  parent_folder                     = var.parent_folder
  enable_hub_and_spoke              = var.enable_hub_and_spoke
  enable_hub_and_spoke_transitivity = var.enable_hub_and_spoke_transitivity
  org_id                            = var.org_id
}
