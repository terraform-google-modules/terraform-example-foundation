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
  constants = {
    org_id          = "816421441114"
    billing_account = "018E0A-48857B-79EB94"

    domains_to_allow = ["clearify.co"]

    groups = {
      org_admins     = "test-gcp-org-admins@test.infra.cft.tips"
      billing_admins = "test-gcp-billing-admins@test.infra.cft.tips"
      billing_data_users = "test-gcp-billing-admins@test.infra.cft.tips"
      audit_data_users = "test-gcp-billing-admins@test.infra.cft.tips"
    }

    default_region = "us-east4"

    //Optional - for development.  Will place all resources under a specific folder instead of org root
    parent_folder = "305593659842"

    // Optional bootstrap configurations
    bootstrap = {
      org_project_creators = []
    }
  }
}
