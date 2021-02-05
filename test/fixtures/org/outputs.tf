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

output "org_id" {
  value       = module.test.org_id
  description = "The organization id"
}

output "scc_notification_name" {
  value       = module.test.scc_notification_name
  description = "Name of SCC Notification"
}

output "parent_resource_id" {
  value       = module.test.parent_resource_id
  description = "The parent resource id"
}

output "parent_resource_type" {
  value       = module.test.parent_resource_type
  description = "The parent resource type"
}

output "common_folder_name" {
  value       = module.test.common_folder_name
  description = "The common folder name"
}

output "org_audit_logs_project_id" {
  value       = module.test.org_audit_logs_project_id
  description = "The org audit logs project ID"
}

output "org_billing_logs_project_id" {
  value       = module.test.org_billing_logs_project_id
  description = "The org billing logs project ID"
}

output "org_secrets_project_id" {
  value       = module.test.org_secrets_project_id
  description = "The org secrets project ID"
}

output "interconnect_project_id" {
  value       = module.test.interconnect_project_id
  description = "The interconnect project ID"
}

output "scc_notifications_project_id" {
  value       = module.test.scc_notifications_project_id
  description = "The SCC notifications project ID"
}

output "dns_hub_project_id" {
  value       = module.test.dns_hub_project_id
  description = "The DNS hub project ID"
}

output "base_net_hub_project_id" {
  value       = module.test.base_net_hub_project_id
  description = "The Base net hub project ID"
}

output "restricted_net_hub_project_id" {
  value       = module.test.restricted_net_hub_project_id
  description = "The Restricted net hub project ID"
}

output "domains_to_allow" {
  value       = module.test.domains_to_allow
  description = "The list of domains to allow users from in IAM."
}

output "logs_export_pubsub_topic" {
  value       = module.test.logs_export_pubsub_topic
  description = "The Pub/Sub topic for destination of log exports"
}

output "logs_export_storage_bucket_name" {
  value       = module.test.logs_export_storage_bucket_name
  description = "The storage bucket for destination of log exports"
}

output "enable_hub_and_spoke" {
  value       = var.enable_hub_and_spoke
  description = "Hub-and-Spoke architecture enabled"
}
