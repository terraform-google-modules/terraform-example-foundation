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

output "private_worker_pool_id" {
  description = "Private worker pool ID."
  value       = google_cloudbuild_worker_pool.private_pool.id
}

output "worker_range_id" {
  description = "The worker IP range ID."
  value       = try(google_compute_global_address.worker_pool_range[0].id, "")
}

output "worker_peered_ip_range" {
  description = "The IP range of the peered service network."
  value       = local.peered_ip_range
}

output "peered_network_id" {
  description = "The ID of the peered network."
  value       = local.peered_network_id
}
