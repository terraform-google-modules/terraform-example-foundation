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

variable "region" {
  type        = string
  description = "The GCP region to deploy instances into"
  default     = "us-central1"
}

variable "network_name" {
  type        = string
  description = "Name for the VPC network"
  default     = "gl-runner-network"
}

variable "create_network" {
  type        = bool
  description = "When set to true, VPC,router and NAT will be auto created"
  default     = true
}

variable "subnetwork_project" {
  type        = string
  description = "The ID of the project in which the subnetwork belongs. If it is not provided, the project_id is used."
  default     = ""
}

variable "subnet_ip" {
  type        = string
  description = "IP range for the subnet"
  default     = "10.10.10.0/24"
}

variable "create_subnetwork" {
  type        = bool
  description = "Whether to create subnetwork or use the one provided via subnet_name"
  default     = true
}

variable "subnet_name" {
  type        = string
  description = "Name for the subnet"
  default     = "gl-runner-subnet"
}

variable "repo_name" {
  type        = string
  description = "Name of the repo for the Github Action"
  default     = ""
}

variable "repo_owner" {
  type        = string
  description = "Owner of the repo for the Github Action"
}

variable "gl_runner_labels" {
  type        = set(string)
  description = "GitHub runner labels to attach to the runners. Docs: https://docs.github.com/en/actions/hosting-your-own-runners/using-labels-with-self-hosted-runners"
  default     = []
}

variable "min_replicas" {
  type        = number
  description = "Minimum number of runner instances"
  default     = 2
}

variable "max_replicas" {
  type        = number
  default     = 10
  description = "Maximum number of runner instances"
}

variable "gitlab_token" {
  type        = string
  sensitive   = true
  description = "Gitlab token that is used for generating Self Hosted Runner Token"
}

variable "service_account" {
  description = "Service account email address"
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Instance name used by Gitlab Runner"
  type        = string
  default     = "gl-runner-vm"
}

variable "network_ip" {
  description = "Private IP address to assign to the instance"
  type        = string
  default     = "10.10.10.8"
}

variable "machine_type" {
  type        = string
  description = "The GCP machine type to deploy"
  default     = "n1-standard-1"
}

variable "source_image_family" {
  type        = string
  description = "Source image family. If neither source_image nor source_image_family is specified, defaults to the latest public Ubuntu image."
  default     = "ubuntu-2204-lts"
}

variable "source_image_project" {
  type        = string
  description = "Project where the source image comes from"
  default     = "ubuntu-os-cloud"
}

variable "source_image" {
  type        = string
  description = "Source disk image. If neither source_image nor source_image_family is specified, defaults to the latest public CentOS image."
  default     = ""
}

variable "startup_script" {
  type        = string
  description = "User startup script to run when instances spin up"
  default     = ""
}

variable "shutdown_script" {
  type        = string
  description = "User shutdown script to run when instances shutdown"
  default     = ""
}

variable "custom_metadata" {
  type        = map(any)
  description = "User provided custom metadata"
  default     = {}
}

variable "cooldown_period" {
  description = "The number of seconds that the autoscaler should wait before it starts collecting information from a new instance."
  type        = number
  default     = 60
}

variable "project_id" {
  type        = string
  description = "ID of the project where the Gitlab runner will be created."
}
