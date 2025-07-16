/**
 * Copyright 2025 Google LLC
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

variable "project_suffix" {
  description = "The name of the GCP project. Max 16 characters with 3 character business unit code."
  type        = string
}

variable "remote_state_bucket" {
  description = "Backend bucket to load remote state information from previous steps."
  type        = string
}

variable "source_image_family" {
  description = "Source image family used for confidential instance. The default is confidential-space."
  type        = string
  default     = "confidential-space"
}

variable "source_image_project" {
  description = "Project where the source image comes from. The default project contains confidential-space-images images. See: https://cloud.google.com/confidential-computing/confidential-space/docs/confidential-space-images"
  type        = string
  default     = "confidential-space-images"
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
  type        = string
  default     = "confidential-instance"
}

variable "confidential_space_keyring_name" {
  description = "Name to be used for KMS Keyring confidential space."
  type        = string
  default     = "workload-key-ring"
}

variable "confidential_space_key_name" {
  description = "Name to be used for KMS Key in confidential space."
  type        = string
  default     = "workload-key"
}

variable "key_rotation_period" {
  description = "Rotation period in seconds to be used for KMS Key."
  type        = string
  default     = "7776000s"
}

variable "confidential_space_location_kms" {
  description = "Case-Sensitive Location for KMS Keyring.."
  type        = string
  default     = "us"
}

variable "image_digest" {
  description = "SHA256 digest of the Docker image.The format is `sha256:xxxxx`"
  type        = string
}

variable "confidential_space_workload_operator" {
  description = "The person who runs the workload that operates on the combined confidential data. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`."
  type        = string
  default     = null
}

variable "location_gcs" {
  description = "Case-Sensitive Location for GCS Bucket."
  type        = string
  default     = "us"
}

variable "gcs_bucket_prefix" {
  description = "Name prefix to be used for GCS Bucket."
  type        = string
  default     = "bkt"
}
