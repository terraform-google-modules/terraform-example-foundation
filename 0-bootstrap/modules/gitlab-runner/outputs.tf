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

output "mig_instance_group" {
  description = "The instance group url of the created MIG"
  value       = module.mig.instance_group
}

output "mig_instance_template" {
  description = "The name of the MIG Instance Template"
  value       = module.mig_template.name
}

output "service_account" {
  description = "Service account email for GCE"
  value       = local.service_account
}
