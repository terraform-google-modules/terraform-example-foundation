/**
 * Copyright 2026 Google LLC
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
  description = "GCP Organization ID."
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "folder_id" {
  description = "The folder ID where the CI/CD project should be created."
  type        = string
}

variable "project_prefix" {
  description = "Prefix to use for project names."
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "app_infra_repos" {
  description = "A list of Cloud Source Repos to be created to hold app infra Terraform configs."
  type        = list(string)
}

variable "remote_tfstate_bucket" {
  description = "Bucket with remote state data to be used by the pipeline."
  type        = string
}

variable "cloud_build_private_worker_pool_id" {
  description = "ID of the Cloud Build private worker pool."
  type        = string
}

variable "cloud_builder_artifact_repo" {
  description = "Artifact Registry (AR) repository that stores TF Cloud Builder images."
  type        = string
}

variable "enforce_vpcsc" {
  description = "Whether to enforce VPC Service Controls."
  type        = bool
  default     = false
}

variable "access_context_manager_policy_id" {
  description = "Access Context Manager Policy ID."
  type        = string
  default     = ""
}

variable "perimeter_name" {
  description = "VPC Service Controls Perimeter Name."
  type        = string
  default     = ""
}

variable "project_budget" {
  description = "Budget configuration."
  type        = any
  default     = {}
}

variable "project_deletion_policy" {
  description = "The deletion policy for the project created."
  type        = string
  default     = "PREVENT"
}

variable "iam_propagation_sleep_duration" {
  description = "The duration to wait for IAM propagation across Cloud Build, Storage, and Artifact Registry."
  type        = string
  default     = "60s"
}

variable "projects_terraform_sa" {
  description = "Projects Step Terraform Service Account."
  type        = string
  default     = ""
}

variable "bucket_prefix" {
  description = "Name prefix to use for state bucket created."
  type        = string
  default     = "bkt"
}

variable "terraform_docker_tag_version" {
  description = "TAG version of the terraform docker image."
  type        = string
  default     = "v1"
}
