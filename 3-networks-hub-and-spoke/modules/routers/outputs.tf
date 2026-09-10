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

output "region1_router1" {
  value       = module.region1_router1
  description = "Router 1 for Region 1"
}

output "region1_router2" {
  value       = module.region1_router2
  description = "Router 2 for Region 1"
}

output "region2_router1" {
  value       = module.region2_router1
  description = "Router 1 for Region 2"
}

output "region2_router2" {
  value       = module.region2_router2
  description = "Router 2 for Region 2"
}
