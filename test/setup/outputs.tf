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

output "project_id" {
  value = module.project.project_id
}

output "parent_folder" {
  description = "Parent folder id"
  value       = split("/", google_folder.test_folder.id)[1]
}

output "sa_key" {
  value     = google_service_account_key.int_test.private_key
  sensitive = true
}

output "terraform_service_account" {
  value = google_service_account.int_test.email
}

output "org_id" {
  value = var.org_id
}

output "billing_account" {
  value = var.billing_account
}

output "group_email" {
  value = var.group_email
}

output "groups" {
  value = {
    required_groups = {
      group_org_admins     = var.group_email
      group_billing_admins = var.group_email
      billing_data_users   = var.group_email
      audit_data_users     = var.group_email
    },
    optional_groups = {
      gcp_security_reviewer    = var.group_email
      gcp_network_viewer       = var.group_email
      gcp_scc_admin            = var.group_email
      gcp_global_secrets_admin = var.group_email
      gcp_kms_admin            = var.group_email

    }
  }
}

output "project_prefix" {
  value = local.project_prefix
}

output "domains_to_allow" {
  value = tolist([var.domain_to_allow])
}

output "essential_contacts_domains_to_allow" {
  value = tolist(["@${var.domain_to_allow}"])
}

output "target_name_server_addresses" {
  value = [
    {
      ipv4_address    = "192.168.0.1",
      forwarding_path = "default"
    },
    {
      ipv4_address    = "192.168.0.2",
      forwarding_path = "default"
    }
  ]

}

output "scc_notification_name" {
  value = "test-scc-notif-${random_string.suffix.result}"
}

output "enable_hub_and_spoke" {
  value = var.example_foundations_mode == "HubAndSpoke" ? "true" : "false"
}

output "enable_hub_and_spoke_transitivity" {
  value = var.example_foundations_mode == "HubAndSpoke" ? "true" : "false"
}

output "create_access_context_manager_access_policy" {
  value = false
}

output "create_unique_tag_key" {
  description = "Set to true to avoid tag key name colision during integrated tests. Tag keys are organization-wide unique names."
  value       = true
}

output "project_deletion_policy" {
  description = "The deletion policy for the project created. Set to `DELETE` during integrated tests so that projects can be destroyed."
  value       = "DELETE"
}

variable "folder_deletion_protection" {
  description = "Prevent Terraform from destroying or recreating the folder. Set to `false` during integrated tests so that folders can be destroyed."
  type        = bool
  default     = false
}
