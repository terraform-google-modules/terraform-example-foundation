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

/******************************************
  Additional policies for SG-based FIs
*******************************************/

// Example for MAS Cloud Advisory Control 21c
module "confidential-computing" {
  source          = "terraform-google-modules/org-policy/google"
  organization_id = local.organization_id
  folder_id       = local.folder_id
  policy_for      = local.policy_for
  policy_type     = "list"
  enforce         = "true"
  constraint      = "constraints/compute.restrictNonConfidentialComputing"
}

// Example for CIS Control 2.3, MAS TRM 12.2.2 and ABS/B/14/Standard/2
module "storage-retention-policy" {
  source            = "terraform-google-modules/org-policy/google"
  organization_id   = local.organization_id
  folder_id         = local.folder_id
  policy_for        = local.policy_for
  constraint        = "constraints/storage.retentionPolicySeconds"
  policy_type       = "list"
  allow             = ["3600", "2592000"] # e.g. 1h and 30d
  allow_list_length = 2
}

