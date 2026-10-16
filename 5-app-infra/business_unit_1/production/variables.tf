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

variable "instance_region" {
  description = "The region where compute instance will be created. A subnetwork must exists in the instance region."
  type        = string
  default     = null
}

variable "remote_state_bucket" {
  description = "Backend bucket to load remote state information from previous steps."
  type        = string
}

variable "universe_domain" {
  description = "The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Cloud Dedicated (GCD)."
  type        = string
  default     = "googleapis.com"
}

variable "confidential_image_digest" {
  description = "SHA256 digest of the Docker image to be used for running the workload in Confidential Space. This value ensures the integrity and immutability of the image, guaranteeing that only the expected and verified code is executed within the confidential environment. Expected format: `sha256:<digest>`."
  type        = string
  default     = ""
}

variable "workload_pool_propagation_sleep_duration" {
  description = "The duration to wait for Workload Identity Pool propagation (e.g., 60s, 2m)."
  type        = string
  default     = "60s"
}

variable "machine_type" {
  description = "Machine type to create, e.g. n1-standard-1"
  type        = string
  default     = "f1-micro"
}

variable "disk_type" {
  description = "Boot disk type, can be either pd-ssd, local-ssd, pd-standard, or hyperdisk-balanced(Air Gapped)"
  type        = string
  default     = "pd-standard"
}

variable "source_image" {
  description = "Source disk image. if not provided defaults to the latest public Rocky Linux 9 optimized for GCP image."
  type        = string
  default     = ""
}

variable "custom_tee_image_reference" {
  description = "Custom TEE container image reference to override the default image derived from cicd_project_id."
  type        = string
  default     = ""
}

variable "confidential_instance_zone" {
  description = "Zone where the confidential compute instance should be created (e.g. us-central1-b, us-central1-c). If null, defaults to us-central1-b."
  type        = string
  default     = null
}
