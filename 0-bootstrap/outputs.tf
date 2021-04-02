/**
 * Copyright 2021 Google LLC
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

output "seed_project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = module.seed_bootstrap.seed_project_id
}

output "terraform_service_account" {
  description = "Email for privileged service account for Terraform."
  value       = module.seed_bootstrap.terraform_sa_email
}

output "terraform_sa_name" {
  description = "Fully qualified name for privileged service account for Terraform."
  value       = module.seed_bootstrap.terraform_sa_name
}

output "gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for foundations pipelines in seed project."
  value       = module.seed_bootstrap.gcs_bucket_tfstate
}

/* ----------------------------------------
    Specific to cloudbuild_module
   ---------------------------------------- */
// Comment-out the cloudbuild_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
output "cloudbuild_project_id" {
  description = "Project where CloudBuild configuration and terraform container image will reside."
  value       = module.cloudbuild_bootstrap.cloudbuild_project_id
}

output "gcs_bucket_cloudbuild_artifacts" {
  description = "Bucket used to store Cloud/Build artifacts in CloudBuild project."
  value       = module.cloudbuild_bootstrap.gcs_bucket_cloudbuild_artifacts
}

output "csr_repos" {
  description = "List of Cloud Source Repos created by the module, linked to Cloud Build triggers."
  value       = module.cloudbuild_bootstrap.csr_repos
}

output "terraform_validator_policies_repo" {
  description = "Cloud Source Repository created for terraform-validator policies."
  value       = google_sourcerepo_repository.gcp_policies
}

output "kms_keyring" {
  description = "KMS Keyring created by the module."
  value       = module.cloudbuild_bootstrap.kms_keyring
}

output "kms_crypto_key" {
  description = "KMS key created by the module."
  value       = module.cloudbuild_bootstrap.kms_crypto_key
}

/* ----------------------------------------
    Specific to jenkins_bootstrap module
   ---------------------------------------- */
//// Un-comment the jenkins_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
//output "cicd_project_id" {
//  description = "Project where the cicd pipeline (Jenkins Agents and terraform builder container image) reside."
//  value       = module.jenkins_bootstrap.cicd_project_id
//}
//
//output "jenkins_agent_gce_instance_id" {
//  description = "Jenkins Agent GCE Instance id."
//  value       = module.jenkins_bootstrap.jenkins_agent_gce_instance_id
//}
//
//output "jenkins_agent_vpc_id" {
//  description = "Jenkins Agent VPC name."
//  value       = module.jenkins_bootstrap.jenkins_agent_vpc_id
//}
//
//output "jenkins_agent_sa_email" {
//  description = "Email for privileged custom service account for Jenkins Agent GCE instance."
//  value       = module.jenkins_bootstrap.jenkins_agent_sa_email
//}
//
//output "jenkins_agent_sa_name" {
//  description = "Fully qualified name for privileged custom service account for Jenkins Agent GCE instance."
//  value       = module.jenkins_bootstrap.jenkins_agent_sa_name
//}
//
//output "gcs_bucket_jenkins_artifacts" {
//  description = "Bucket used to store Jenkins artifacts in Jenkins project."
//  value       = module.jenkins_bootstrap.gcs_bucket_jenkins_artifacts
//}
