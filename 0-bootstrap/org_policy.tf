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

locals {
  organization_id = var.parent_folder != "" ? null : var.org_id
  folder_id       = var.parent_folder != "" ? var.parent_folder : null
  policy_for      = var.parent_folder != "" ? "folder" : "organization"

  boolean_type_organization_policies = toset([
    "compute.skipDefaultNetworkCreation",
    "iam.automaticIamGrantsForDefaultServiceAccounts"
  ])
}

module "organization_policies_type_boolean" {
  source   = "terraform-google-modules/org-policy/google"
  version  = "~> 5.1"
  for_each = local.boolean_type_organization_policies

  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "boolean"
  enforce         = "true"
  constraint      = "constraints/${each.value}"
}
