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

// Must include the domain of the organization you are deploying the foundation.
domains_to_allow = ["example.com"]

essential_contacts_domains_to_allow = ["@example.com"]

group_org_admins = "gcp-organization-admins@example.com"

group_billing_admins = "gcp-billing-admins@example.com"

billing_data_users = "gcp-billing-data-users@example.com"

audit_data_users = "gcp-security-admins@example.com"

scc_notification_name = "scc-notify"

backend_bucket = "<TERRAFORM-STATE-BUCKET>"

//scc_notification_filter = "state=\\\"ACTIVE\\\""

//enable_hub_and_spoke = true

//create_access_context_manager_access_policy = false

// if you enable hub and spoke you need to provide
// the service account that will be used in the network step
//networks_step_terraform_service_account = "terraform-net-sa@example-project-2334.iam.gserviceaccount.com"
