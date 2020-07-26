/**
 * Copyright 2020 Google LLC
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

output "dev_restricted_access_level_name" {
  description = "Dev access context manager access level name"
  value       = module.dev.restricted_access_level_name
}

output "dev_restricted_service_perimeter_name" {
  description = "Dev access context manager service perimeter name"
  value       = module.dev.restricted_service_perimeter_name
}

output "nonprod_restricted_access_level_name" {
  description = "Nonprod access context manager access level name"
  value       = module.nonprod.restricted_access_level_name
}

output "nonprod_restricted_service_perimeter_name" {
  description = "Nonprod access context manager service perimeter name"
  value       = module.nonprod.restricted_service_perimeter_name
}

output "prod_restricted_access_level_name" {
  description = "Prod access context manager access level name"
  value       = module.prod.restricted_access_level_name
}

output "prod_restricted_service_perimeter_name" {
  description = "Prod access context manager service perimeter name"
  value       = module.prod.restricted_service_perimeter_name
}
