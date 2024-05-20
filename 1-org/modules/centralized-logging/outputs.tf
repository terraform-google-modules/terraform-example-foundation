/**
 * Copyright 2022 Google LLC
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

output "storage_destination_name" {
  description = "The resource name for the destination Storage."
  value       = try(module.destination_storage[0].resource_name, "")
}

output "pubsub_destination_name" {
  description = "The resource name for the destination Pub/Sub."
  value       = try(module.destination_pubsub[0].resource_name, "")
}

output "project_logbucket_name" {
  description = "The resource name for the Log Bucket created for the project destination."
  value       = var.project_options != null ? module.destination_aggregated_logs[0].resource_name : ""
}

output "project_linked_dataset_name" {
  description = "The resource name of the Log Bucket linked BigQuery dataset for the project destination."
  value       = var.project_options != null && var.project_options.enable_analytics ? module.destination_aggregated_logs[0].linked_dataset_name : ""
}

output "billing_sink_names" {
  description = "Map of log sink names with billing suffix"
  value = {
    for key, options in local.destinations_options :
    key => "${coalesce(options.logging_sink_name, local.logging_sink_name_map[key])}-billing-${random_string.suffix.result}"
  }
}
