/**
 * Copyright 2023 Google LLC
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

output "shared_vpc_project_id" {
  description = "Project id for shared VPC network."
  value       = module.shared_vpc_host_project.project_id
}

output "shared_vpc_project_number" {
  description = "Project number for shared VPC."
  value       = module.shared_vpc_host_project.project_number
}
