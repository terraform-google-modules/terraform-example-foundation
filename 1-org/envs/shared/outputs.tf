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
  value       = var.org_id
  description = "The organization id"
}

output "scc_notification_name" {
  value       = var.scc_notification_name
  description = "Name of SCC Notification"
}

output "parent_resource_id" {
  value       = local.parent_resource_id
  description = "The parent resource id"
}

output "parent_resource_type" {
  value       = local.parent_resource_type
  description = "The parent resource type"
}

output "common_folder_name" {
  value       = google_folder.common.name
  description = "The common folder name"
}

output "org_audit_logs_project_id" {
  value       = module.org_audit_logs.project_id
  description = "The org audit logs project ID"
}

output "org_billing_logs_project_id" {
  value       = module.org_billing_logs.project_id
  description = "The org billing logs project ID"
}

output "org_secrets_project_id" {
  value       = module.org_secrets.project_id
  description = "The org secrets project ID"
}

output "interconnect_project_id" {
  value       = module.interconnect.project_id
  description = "The Dedicated Interconnect project ID"
}

output "scc_notifications_project_id" {
  value       = module.scc_notifications.project_id
  description = "The SCC notifications project ID"
}

output "dns_hub_project_id" {
  value       = module.dns_hub.project_id
  description = "The DNS hub project ID"
}

output "base_net_hub_project_id" {
  value       = try(module.base_network_hub[0].project_id, null)
  description = "The Base Network hub project ID"
}

output "restricted_net_hub_project_id" {
  value       = try(module.restricted_network_hub[0].project_id, null)
  description = "The Restricted Network hub project ID"
}

output "domains_to_allow" {
  value       = var.domains_to_allow
  description = "The list of domains to allow users from in IAM."
}

output "logs_export_pubsub_topic" {
  value       = module.pubsub_destination.resource_name
  description = "The Pub/Sub topic for destination of log exports"
}

output "logs_export_storage_bucket_name" {
  value       = module.storage_destination.resource_name
  description = "The storage bucket for destination of log exports"
}
