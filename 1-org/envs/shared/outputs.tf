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
  value       = local.org_id
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

output "network_folder_name" {
  value       = google_folder.network.name
  description = "The network folder name."
}

output "org_audit_logs_project_id" {
  value       = module.org_audit_logs.project_id
  description = "The org audit logs project ID."
}

output "org_billing_export_project_id" {
  value       = module.org_billing_export.project_id
  description = "The org billing export project ID"
}

output "org_secrets_project_id" {
  value       = module.org_secrets.project_id
  description = "The org secrets project ID"
}

output "common_kms_project_id" {
  value       = module.common_kms.project_id
  description = "The org Cloud Key Management Service (KMS) project ID"
}

output "interconnect_project_id" {
  value       = module.interconnect.project_id
  description = "The Dedicated Interconnect project ID"
}

output "interconnect_project_number" {
  value       = module.interconnect.project_number
  description = "The Dedicated Interconnect project number"
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

output "restricted_net_hub_project_number" {
  value       = try(module.restricted_network_hub[0].project_number, null)
  description = "The Restricted Network hub project number"
}

output "domains_to_allow" {
  value       = var.domains_to_allow
  description = "The list of domains to allow users from in IAM."
}

output "logs_export_pubsub_topic" {
  value       = module.logs_export.pubsub_destination_name
  description = "The Pub/Sub topic for destination of log exports"
}

output "logs_export_storage_bucket_name" {
  value       = module.logs_export.storage_destination_name
  description = "The storage bucket for destination of log exports"
}

output "logs_export_project_logbucket_name" {
  description = "The resource name for the Log Bucket created for the project destination."
  value       = module.logs_export.project_logbucket_name
}

output "logs_export_project_linked_dataset_name" {
  description = "The resource name of the Log Bucket linked BigQuery dataset for the project destination."
  value       = module.logs_export.project_linked_dataset_name
}

output "billing_sink_names" {
  value       = module.logs_export.billing_sink_names
  description = "The name of the sinks under billing account level."
}

output "tags" {
  value       = local.tags_output
  description = "Tag Values to be applied on next steps."
}

output "shared_vpc_projects" {
  value       = { for k, v in module.base_restricted_environment_network : k => v }
  description = "Base and restricted shared VPC Projects info grouped by environment (development, nonproduction, production)."
}

output "cai_monitoring_artifact_registry" {
  value       = module.cai_monitoring.artifact_registry_name
  description = "CAI Monitoring Cloud Function Artifact Registry name."
}

output "cai_monitoring_asset_feed" {
  value       = module.cai_monitoring.asset_feed_name
  description = "CAI Monitoring Cloud Function Organization Asset Feed name."
}

output "cai_monitoring_bucket" {
  value       = module.cai_monitoring.bucket_name
  description = "CAI Monitoring Cloud Function Source Bucket name."
}

output "cai_monitoring_topic" {
  value       = module.cai_monitoring.topic_name
  description = "CAI Monitoring Cloud Function Pub/Sub Topic name."
}
