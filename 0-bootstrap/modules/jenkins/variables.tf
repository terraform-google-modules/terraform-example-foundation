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

/******************************************
  Required variables
*******************************************/

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "group_org_admins" {
  description = "Google Group for GCP Organization Administrators"
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "jenkins_agent_gce_name" {
  description = "Jenkins Agent GCE Instance name."
  type        = string
  default     = "jenkins-agent-02"
}

variable "jenkins_agent_gce_ssh_user" {
  description = "Jenkins Agent GCE Instance SSH username."
  type        = string
  default     = "jenkins"
}

variable "jenkins_agent_gce_ssh_pub_key_file" {
  description = "Jenkins Agent GCE Instance SSH Public Key."
  type        = string
  default     = "./jenkins-agent-ssh-pub-keys/ssh-pub-key-01.txt"
}

variable "terraform_sa_email" {
  description = "Email for terraform service account."
  type        = string
}

variable "terraform_sa_name" {
  description = "Fully-qualified name of the terraform service account."
  type        = string
}

variable "terraform_state_bucket" {
  description = "Default state bucket, used in Cloud Build substitutions."
  type        = string
}

/******************************************
  Optional variables
*******************************************/

variable "project_labels" {
  description = "Labels to apply to the project."
  type        = map(string)
  default     = {}
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "prj"
}

variable "activate_apis" {
  description = "List of APIs to enable in the Cloudbuild project."
  type        = list(string)

  default = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com"
  ]
}

variable "sa_enable_impersonation" {
  description = "Allow org_admins group to impersonate service account & enable APIs required."
  type        = bool
  default     = false
}

variable "storage_bucket_labels" {
  description = "Labels to apply to the storage bucket."
  type        = map(string)
  default     = {}
}

variable "cloud_source_repos" {
  description = "List of Cloud Source Repo's to create with CloudBuild triggers."
  type        = list(string)

  default = [
    "gcp-org",
    "gcp-networks",
    "gcp-projects",
  ]
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  type        = string
  default     = ""
}

variable "terraform_version" {
  description = "Default terraform version."
  type        = string
  default     = "0.12.24"
}

variable "terraform_version_sha256sum" {
  description = "sha256sum for default terraform version."
  type        = string
  default     = "602d2529aafdaa0f605c06adb7c72cfb585d8aa19b3f4d8d189b42589e27bf11"
}