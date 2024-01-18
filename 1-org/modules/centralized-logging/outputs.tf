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

output "logbucket_destination_name" {
  description = "The resource name for the destination Log Bucket."
  value       = try(module.destination_logbucket[0].resource_name, "")
}

output "logbucket_linked_dataset_name" {
  description = "The resource name of the Log Bucket linked BigQuery dataset."
  value       = try(module.destination_logbucket[0].linked_dataset_name, "")
}

output "project_logbucket_name" {
  description = "The resource name for the Log Bucket created for the project destination."
  value       = var.project_options != null ? google_logging_project_bucket_config.prj_logs_bucket[0].bucket_id : ""
}

output "project_linked_dataset_name" {
  description = "The resource name of the Log Bucket linked BigQuery dataset for the project destination."
  value       = var.project_options != null && var.project_options.enable_analytics ? google_logging_linked_dataset.prj_logs_linked_dataset[0].link_id : ""
}
