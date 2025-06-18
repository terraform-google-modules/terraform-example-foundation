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

variable "environment" {
  description = "The environment the single project belongs to"
  type        = string
}

variable "business_unit" {
  description = "The business (ex. business_unit_1)."
  type        = string
  default     = "business_unit_1"
}

variable "region" {
  description = "The GCP region to create and test resources in"
  type        = string
  default     = "us-central1"
}

variable "num_instances" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  default     = "f1-micro"
}

variable "hostname" {
  description = "Hostname of instances"
  default     = "example-app"
}

variable "project_suffix" {
  description = "The name of the GCP project. Max 16 characters with 3 character business unit code."
  type        = string
}

variable "remote_state_bucket" {
  description = "Backend bucket to load remote state information from previous steps."
  type        = string
}

variable "source_image_family" {
  description = "Source image family used for confidential instance. If none source_image_family is specified, defaults to ubuntu-2204-lts."
  type        = string
  default     = ""
}

variable "source_image_project" {
  description = "Project where the source image comes from. The default project contains ubuntu-os-cloud images."
  type        = string
  default     = ""
}

variable "confidential_machine_type" {
  description = "Machine type to create for confidential instance."
  type        = string
  default     = "n2d-standard-2"
}

variable "confidential_instance_type" {
  description = "(Optional) Defines the confidential computing technology the instance uses. SEV is an AMD feature. TDX is an Intel feature. One of the following values is required: SEV, SEV_SNP, TDX. "
  type        = string
  default     = "SEV"
}

variable "cpu_platform" {
  description = "The CPU platform used by this instance. If confidential_instance_type is set as SEV, then it is an AMD feature. TDX is an Intel feature."
  type        = string
  default     = "AMD Milan"
}

variable "confidential_hostname" {
  description = "Hostname of confidential instance."
  default     = "confidential-instance"
}

variable "artifact_registry_location" {
  description = "The location to create the Artifact Registry used by confidential space."
  type        = string
  default     = "us"
}

variable "docker_image_reference" {
  description = "Docker image used by confidential space."
  type        = string
  default     = ""
}

