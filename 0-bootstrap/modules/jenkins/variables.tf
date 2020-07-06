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

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "jenkins_agent_gce_name" {
  description = "Jenkins Agent GCE Instance name."
  type        = string
  default     = "jenkins-agent-01"
}

variable "jenkins_agent_gce_machine_type" {
  description = "Jenkins Agent GCE Instance type."
  type        = string
  default     = "n1-standard-1"
}

variable "jenkins_agent_gce_ssh_user" {
  description = "Jenkins Agent GCE Instance SSH username."
  type        = string
  default     = "jenkins"
}

variable "jenkins_agent_gce_ssh_pub_key_file" {
  description = "File with the SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Master holds the SSH private key."
  type        = string
  default     = "./jenkins-agent-ssh-pub-keys/metadata-ssh-pub-keys"
}

variable "jenkins_sa_email" {
  description = "Email for Jenkins Agent service account."
  type        = string
  default     = "jenkins-agent-gce-sa"
}

variable "jenkins_master_ip_addresses" {
  description = "A list of IP Addresses and masks of the Jenkins Master in the form ['0.0.0.0/0']. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance."
  type        = list(string)
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
    "storage-api.googleapis.com",
    "cloudkms.googleapis.com"
  ]
}

variable "sa_enable_impersonation" {
  description = "Allow org_admins group to impersonate service account & enable APIs required."
  type        = bool
  default     = false
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  type        = string
  default     = ""
}
