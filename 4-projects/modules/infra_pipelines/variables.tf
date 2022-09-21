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

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "prj"
}

variable "cloudbuild_project_id" {
  description = "The project id where the pipelines and repos should be created."
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with."
  type        = string
}

variable "app_infra_repos" {
  description = "A list of Cloud Source Repos to be created to hold app infra Terraform configs."
  type        = list(string)
}

variable "terraform_docker_tag_version" {
  description = "TAG version of the terraform docker image."
  type        = string
  default     = "v1"
}

variable "cloud_builder_artifact_repo" {
  description = "GAR Repo that stores TF Cloud Builder images."
  type        = string

}

variable "folders_to_grant_browser_role" {
  description = "List of folders to grant browser role to the cloud build service account. Used by terraform validator to able to load IAM policies."
  type        = list(string)
  default     = []
}
