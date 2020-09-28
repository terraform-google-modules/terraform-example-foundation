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
  deploy_at_root       = lookup(local.constants, "parent_folder", "") != "" ? false : true
  parent = local.deploy_at_root ? "organizations/${local.constants.org_id}" : "folders/${local.constants.parent_folder}"

}

output "values" {
  description = "Constant configuration values which apply across layers and environments."
  value       = local.constants
}

output "deploy_at_root" {
  description = "Whether to deploy at the root of the organization or in a folder."
  value       = local.deploy_at_root
}

output "parent" {
  description = "The parent being deployed into, either the org or a folder."
  value = local.parent
}
