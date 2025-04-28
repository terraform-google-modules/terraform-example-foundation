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

# Must include the domain of the organization you are deploying the foundation.
domains_to_allow = ["example.com"]

essential_contacts_domains_to_allow = ["@example.com"]

scc_notification_name = "scc-notify"

remote_state_bucket = "REMOTE_STATE_BUCKET"

log_export_storage_location = "US"

billing_export_dataset_location = "US"

//scc_notification_filter = "state=\\\"ACTIVE\\\""

//enable_hub_and_spoke = true

//create_access_context_manager_access_policy = false

// Optional - If you are deploying Foundation Example in a parent folder
// consider using below create_unique_tag_key var because as Tag Keys are
// unique organization-wide it will add a random suffix at each tag key

//create_unique_tag_key = true
