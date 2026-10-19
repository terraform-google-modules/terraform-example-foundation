/**
 * Copyright 2026 Google LLC
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

output "routers" {
  description = "Map of all created Cloud Router module instances keyed by router identifier."
  value       = { for k, v in module.routers : k => v }
}

output "router_names" {
  description = "Map of Cloud Router names keyed by router identifier."
  value       = { for k, v in module.routers : k => v.router.name }
}

output "router_ids" {
  description = "Map of Cloud Router IDs keyed by router identifier."
  value       = { for k, v in module.routers : k => v.router.id }
}
