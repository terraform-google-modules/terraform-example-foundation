/**
 * Copyright 2023 Google LLC
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

org_id = "960896122806" # format "000000000000"

billing_account = "013E70-8D0B90-B1DB07" # format "000000-000000-000000"

// For enabling the automatic groups creation, uncoment the
// variables and update the values with the group names
groups = {
  create_required_groups = true # Change to true to create the required_groups
  # create_optional_groups = false # Change to true to create the optional_groups
  billing_project = "kollectly-billing-project" # Fill to create required or optional groups
  required_groups = {
    group_org_admins     = "gcp-organization-admins@kollectly.ai" # example "gcp-organization-admins@example.com"
    group_billing_admins = "gcp-billing-admins@kollectly.ai"      # example "gcp-billing-admins@example.com"
    billing_data_users   = "gcp-billing-data@kollectly.ai"        # example "gcp-billing-data@example.com"
    audit_data_users     = "gcp-audit-data@kollectly.ai"          # example "gcp-audit-data@example.com"
  }
  # optional_groups = {
  #   gcp_security_reviewer      = "" #"gcp_security_reviewer_local_test@example.com"
  #   gcp_network_viewer         = "" #"gcp_network_viewer_local_test@example.com"
  #   gcp_scc_admin              = "" #"gcp_scc_admin_local_test@example.com"
  #   gcp_global_secrets_admin   = "" #"gcp_global_secrets_admin_local_test@example.com"
  #   gcp_kms_admin              = "" #"gcp_kms_admin_local_test@example.com"
  # }
}

default_region     = "australia-southeast1"
default_region_2   = "australia-southeast2"
default_region_gcs = "australia-southeast1"
default_region_kms = "au"


/* ----------------------------------------
    Specific to github_bootstrap
   ---------------------------------------- */
#  Un-comment github_bootstrap and its outputs if you want to use GitHub Actions instead of Cloud Build
gh_repos = {
  owner        = "collectly-core",
  bootstrap    = "kollectly-terraform-foundation",
  organization = "kollectly-terraform-foundation",
  environments = "kollectly-terraform-foundation",
  networks     = "kollectly-terraform-foundation",
  projects     = "kollectly-terraform-foundation",
}
#
#  to prevent saving the `gh_token` in plain text in this file,
#  export the GitHub fine grained access token in the command line
#  as an environment variable before running terraform.
#  Run the following command in your shell:
#   export TF_VAR_gh_token="YOUR-FINE-GRAINED-ACCESS-TOKEN"
