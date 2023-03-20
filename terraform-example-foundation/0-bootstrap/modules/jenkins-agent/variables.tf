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

/* ----------------------------------------
    Specific to CICD Project
   ---------------------------------------- */
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

variable "jenkins_agent_gce_subnetwork_cidr_range" {
  description = "The subnetwork to which the Jenkins Agent will be connected to (in CIDR range 0.0.0.0/0)"
  type        = string
}

variable "jenkins_agent_gce_private_ip_address" {
  description = "The private IP Address of the Jenkins Agent. This IP Address must be in the CIDR range of `jenkins_agent_gce_subnetwork_cidr_range` and be reachable through the VPN that exists between on-prem (Jenkins Controller) and GCP (CICD Project, where the Jenkins Agent is located)."
  type        = string
}

variable "jenkins_agent_gce_ssh_pub_key" {
  description = "SSH public key needed by the Jenkins Agent GCE Instance. The Jenkins Controller holds the SSH private key. The correct format is `'ssh-rsa [KEY_VALUE] [USERNAME]'`"
  type        = string
}

variable "jenkins_agent_sa_email" {
  description = "Email for Jenkins Agent service account."
  type        = string
  default     = "jenkins-agent-gce"
}

variable "jenkins_controller_subnetwork_cidr_range" {
  description = "A list of CIDR IP ranges of the Jenkins Controller in the form ['0.0.0.0/0']. Usually only one IP in the form '0.0.0.0/32'. Needed to create a FW rule that allows communication with the Jenkins Agent GCE Instance."
  type        = list(string)
}

variable "nat_bgp_asn" {
  type        = number
  description = "BGP ASN for NAT cloud route. This is needed to allow the Jenkins Agent to download packages and updates from the internet without having an external IP address."
}

variable "vpn_shared_secret" {
  description = "The shared secret used in the VPN"
  type        = string
}

variable "on_prem_vpn_public_ip_address" {
  description = "The public IP Address of the Jenkins Controller."
  type        = string
}

variable "on_prem_vpn_public_ip_address2" {
  description = "The secondpublic IP Address of the Jenkins Controller."
  type        = string
}

variable "router_asn" {
  type        = number
  description = "BGP ASN for cloud routes."
  default     = "64515"
}

variable "bgp_peer_asn" {
  type        = number
  description = "BGP ASN for peer cloud routes."
  default     = "64513"
}

variable "tunnel0_bgp_peer_address" {
  type        = string
  description = "BGP peer address for tunnel 0"
}

variable "tunnel0_bgp_session_range" {
  type        = string
  description = "BGP session range for tunnel 0"
}

variable "tunnel1_bgp_peer_address" {
  type        = string
  description = "BGP peer address for tunnel 1"
}

variable "tunnel1_bgp_session_range" {
  type        = string
  description = "BGP session range for tunnel 1"
}

/* ----------------------------------------
    Specific to Seed Project
   ---------------------------------------- */

variable "terraform_sa_names" {
  description = "Fully-qualified name of the Terraform Service Accounts. It must be supplied by the Seed Project"
  type        = map(string)
}

variable "terraform_state_bucket" {
  description = "Default state bucket, used in Cloud Build substitutions. It must be supplied by the Seed Project"
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
  description = "List of APIs to enable in the CICD project."
  type        = list(string)

  default = [
    "serviceusage.googleapis.com",
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "bigquery.googleapis.com", // required to create the BQ log sinks
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "admin.googleapis.com",
    "appengine.googleapis.com",
    "storage-api.googleapis.com",
    "dns.googleapis.com",
  ]
}

variable "sa_enable_impersonation" {
  description = "Allow org_admins group to impersonate service account & enable APIs required."
  type        = bool
  default     = false
}

variable "service_account_prefix" {
  description = "Name prefix to use for service accounts."
  type        = string
  default     = "sa"
}

variable "storage_bucket_prefix" {
  description = "Name prefix to use for storage buckets."
  type        = string
  default     = "bkt"
}

variable "storage_bucket_labels" {
  description = "Labels to apply to the storage bucket."
  type        = map(string)
  default     = {}
}

variable "folder_id" {
  description = "The ID of a folder to host this project"
  type        = string
  default     = ""
}

variable "terraform_version" {
  description = "Default terraform version."
  type        = string
  default     = "1.3.0"
}

variable "terraform_version_sha256sum" {
  description = "sha256sum for default terraform version."
  type        = string
  default     = "380ca822883176af928c80e5771d1c0ac9d69b13c6d746e6202482aedde7d457"
}
