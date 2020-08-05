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
  description = "development access context manager access level name"
  value       = module.development.restricted_access_level_name
}

output "dev_restricted_service_perimeter_name" {
  description = "development access context manager service perimeter name"
  value       = module.development.restricted_service_perimeter_name
}

output "nonprod_restricted_access_level_name" {
  description = "non-production access context manager access level name"
  value       = module.non-production.restricted_access_level_name
}

output "nonprod_restricted_service_perimeter_name" {
  description = "non-production access context manager service perimeter name"
  value       = module.non-production.restricted_service_perimeter_name
}

output "prod_restricted_access_level_name" {
  description = "production access context manager access level name"
  value       = module.production.restricted_access_level_name
}

output "prod_restricted_service_perimeter_name" {
  description = "production access context manager service perimeter name"
  value       = module.production.restricted_service_perimeter_name
}
