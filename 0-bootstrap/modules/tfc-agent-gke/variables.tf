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

variable "project_id" {
  type        = string
  description = "The Google Cloud Platform project ID to deploy Terraform Cloud agent cluster"
}

variable "project_number" {
  description = "The project number to host the cluster in"
}

variable "region" {
  type        = string
  description = "The GCP region to use when deploying resources"
  default     = "us-central1"
}

variable "zones" {
  type        = list(string)
  description = "The GCP zone to use when deploying resources"
  default     = ["us-central1-a"]
}

variable "nat_bgp_asn" {
  type        = number
  description = "BGP ASN for NAT cloud routes."
  default     = 64514
}

variable "nat_enabled" {
  type    = bool
  default = true
}

variable "nat_num_addresses" {
  type    = number
  default = 2
}

variable "ip_range_pods_name" {
  type        = string
  description = "The secondary IP range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  type        = string
  description = "The secondary IP range to use for services"
  default     = "ip-range-scv"
}

variable "ip_range_pods_cidr" {
  type        = string
  description = "The secondary IP range CIDR to use for pods"
  default     = "192.168.0.0/18"
}

variable "ip_range_services_cider" {
  type        = string
  description = "The secondary IP range CIDR to use for services"
  default     = "192.168.64.0/18"
}

variable "network_name" {
  type        = string
  description = "Name for the VPC network"
  default     = "tfc-agent-network"
}

variable "subnet_ip" {
  type        = string
  description = "IP range for the subnet"
  default     = "10.0.0.0/17"
}

variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = "tfc-agent-subnet"
}

variable "network_project_id" {
  type        = string
  description = <<-EOF
    The project ID of the shared VPCs host (for shared vpc support).
    If not provided, the project_id is used
  EOF
  default     = ""
}

variable "machine_type" {
  type        = string
  description = "Machine type for TFC agent node pool"
  default     = "n1-standard-4"
}

variable "max_node_count" {
  type        = number
  description = "Maximum number of nodes in the TFC agent node pool"
  default     = 4
}

variable "min_node_count" {
  type        = number
  description = "Minimum number of nodes in the TFC agent node pool"
  default     = 2
}

variable "create_service_account" {
  description = "Set to true to create a new service account, false to use an existing one"
  type        = bool
  default     = true
}

variable "service_account_email" {
  type        = string
  description = "Optional Service Account for the GKE nodes, required if create_service_account is set to false"
  default     = ""
}

variable "service_account_id" {
  type        = string
  description = "Optional Service Account for the GKE nodes, required if create_service_account is set to false"
  default     = ""
}

variable "tfc_agent_k8s_secrets" {
  type        = string
  description = "Name for the k8s secret required to configure TFC agent on GKE"
  default     = "tfc-agent-k8s-secrets"
}

variable "tfc_agent_address" {
  type        = string
  description = "The HTTP or HTTPS address of the Terraform Cloud/Enterprise API"
  default     = "https://app.terraform.io"
}

variable "tfc_agent_single" {
  type        = bool
  description = <<-EOF
    Enable single mode. This causes the agent to handle at most one job and
    immediately exit thereafter. Useful for running agents as ephemeral
    containers, VMs, or other isolated contexts with a higher-level scheduler
    or process supervisor.
  EOF
  default     = false
}

variable "tfc_agent_auto_update" {
  type        = string
  description = "Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor"
  default     = "minor"
}

variable "tfc_agent_name_prefix" {
  type        = string
  description = "This name may be used in the Terraform Cloud user interface to help easily identify the agent"
  default     = "tfc-agent-k8s"
}

variable "tfc_agent_image" {
  type        = string
  description = "The Terraform Cloud agent image to use"
  default     = "hashicorp/tfc-agent:latest"
}

variable "tfc_agent_memory_request" {
  type        = string
  description = "Memory request for the Terraform Cloud agent container"
  default     = "2Gi"
}

variable "tfc_agent_cpu_request" {
  type        = string
  description = "CPU request for the Terraform Cloud agent container"
  default     = "2"
}

variable "tfc_agent_ephemeral_storage" {
  type        = string
  description = "A temporary storage for a container that gets wiped out and lost when the container is stopped or restarted"
  default     = "1Gi"
}

variable "autopilot_gke_io_warden_version" {
  type        = string
  description = "Autopilot GKE IO Warden Version"
  default     = "2.7.41"
}

variable "tfc_agent_token" {
  type        = string
  description = "Terraform Cloud agent token. (Organization Settings >> Agents)"
  sensitive   = true
}

variable "tfc_agent_min_replicas" {
  type        = string
  description = "Minimum replicas for the Terraform Cloud agent pod autoscaler"
  default     = "1"
}

variable "tfc_agent_max_replicas" {
  type        = string
  description = "Maximum replicas for the Terraform Cloud agent pod autoscaler"
  default     = "10"
}

variable "firewall_enable_logging" {
  type    = bool
  default = true
}

variable "private_service_connect_ip" {
  type    = string
  default = "10.10.64.5"
}
