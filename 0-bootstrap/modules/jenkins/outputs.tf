/**
 * Copyright 2019 Google LLC
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

output "cicd_project_id" {
  description = "Project where the cicd pipeline (Jenkins Agents and terraform builder container image) reside."
  value       = module.cicd_project.project_id
}

output "jenkins_agent_gce_instance_id" {
  description = "Jenkins Agent GCE Instance id."
  value       = google_compute_instance.jenkins_agent_gce_instance.id
}

output "jenkins_sa_email" {
  description = "Email for privileged custom service account for Jenkins Agent GCE instance."
  value       = google_service_account.jenkins_agent_gce_sa.email
}
