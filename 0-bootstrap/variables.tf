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

variable "group_billing_admins" {
  description = "Google Group for GCP Billing Administrators"
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "parent_folder" {
  description = "Optional - if using a folder for testing."
  type        = string
  default     = ""
}

variable "org_project_creators" {
  description = "Additional list of members to have project creator role across the organization. Prefix of group: user: or serviceAccount: is required."
  type        = list(string)
  default     = []
}

variable "skip_gcloud_download" {
  description = "Whether to skip downloading gcloud (assumes gcloud is already available outside the module)"
  type        = bool
  default     = true
}

/* ----------------------------------------
    Specific to jenkins_bootstrap module
   ---------------------------------------- */

# # Un-comment the jenkins_bootstrap module and its outputs if you want to use Jenkins instead of Cloud Build
# variable "jenkins_agent_gce_subnetwork_cidr_range" {
#  description = "The subnetwork to which the Jenkins Agent will be connected to (in CIDR range 0.0.0.0/0)"
#  type        = string
# }

# variable "jenkins_agent_gce_private_ip_address" {
#  description = "The private IP Address of the Jenkins Agent. This IP Address must be in the CIDR range of `jenkins_agent_gce_subnetwork_cidr_range` and be reachable through the VPN that exists between on-prem (Jenkins Master) and GCP (CICD Project, where the Jenkins Agent is located)."
#  type        = string
# }

# variable "jenkins_agent_gce_ssh_pub_key" {
#  description = "SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Master holds the SSH private key. The correct format is `'ssh-rsa [KEY_VALUE] [USERNAME]'`"
#  type        = string
# }

# variable "jenkins_agent_sa_email" {
#  description = "Email for Jenkins Agent service account."
#  type        = string
#  default     = "jenkins-agent-gce"
# }

# variable "jenkins_master_subnetwork_cidr_range" {
#  description = "A list of CIDR IP ranges of the Jenkins Master in the form ['0.0.0.0/0']. Usually only one IP in the form '0.0.0.0/32'. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance."
#  type        = list(string)
# }

# variable "nat_bgp_asn" {
#  type        = number
#  description = "BGP ASN for NAT cloud route. This is needed to allow the Jenkins Agent to download packages and updates from the internet without having an external IP address."
# }
