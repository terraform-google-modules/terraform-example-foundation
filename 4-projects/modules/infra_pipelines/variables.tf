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

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "cloudbuild_project_id" {
  description = "The project id where the pipelines and repos should be created."
  type        = string
}

variable "remote_tfstate_bucket" {
  description = "Bucket with remote state data to be used by the pipeline."
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associated this project with."
  type        = string
}

variable "terraform_docker_tag_version" {
  description = "TAG version of the terraform docker image."
  type        = string
  default     = "v1"
}

variable "cloud_builder_artifact_repo" {
  description = "Artifact Registry (AR) repository that stores TF Cloud Builder images."
  type        = string

}

variable "private_worker_pool_id" {
  description = "ID of the Cloud Build private worker pool."
  type        = string
}

variable "bucket_prefix" {
  description = "Name prefix to use for state bucket created."
  type        = string
  default     = "bkt"
}

variable "vpc_service_control_attach_enabled" {
  description = "Whether the project will be attached to a VPC Service Control Perimeter in ENFORCED MODE."
  type        = bool
  default     = false
}


variable "vpc_service_control_attach_dry_run" {
  description = "Whether the project will be attached to a VPC Service Control Perimeter with an explicit dry run spec flag, which may use different values for the dry run perimeter compared to the ENFORCED perimeter."
  type        = bool
  default     = false
}

variable "cloudbuildv2_repository_config" {
  description = <<-EOT
  Configuration for integrating repositories with Cloud Build v2:
    - repo_type: Specifies the type of repository. Supported types are 'GITHUBv2', 'GITLABv2', and 'CSR'.
    - repositories: A map of repositories to be created. The key must match the exact name of the repository. Each repository is defined by:
        - repository_name: The name of the repository.
        - repository_url: The HTTPS clone URL of the repository ending in `.git`.
    - github_pat: (Optional) The personal access token for GitHub authentication.
    - github_app_id: (Optional) The application ID for a GitHub App used for authentication.
    - gitlab_read_authorizer_credential: (Optional) The read authorizer credential for GitLab access.
    - gitlab_authorizer_credential: (Optional) The authorizer credential for GitLab access.

  Note: If 'cloudbuildv2' is not configured, CSR (Cloud Source Repositories) will be used by default.
  EOT
  type = object({
    repo_type = string # Supported values are: GITHUBv2, GITLABv2 and CSR
    # repositories to be created, the key name must be exactly the same as the repository name
    repositories = map(object({
      repository_name = string,
      repository_url  = string,
    }))
    # Credential Config for each repository type
    github_pat                        = optional(string)
    github_app_id                     = optional(string)
    gitlab_read_authorizer_credential = optional(string)
    gitlab_authorizer_credential      = optional(string)
  })

  # If cloudbuildv2 is not configured, then auto-creation with CSR will be used
  default = {
    repo_type    = "CSR"
    repositories = {}
  }
  validation {
    condition = (
      var.cloudbuildv2_repository_config.repo_type == "GITHUBv2" ? (
        var.cloudbuildv2_repository_config.github_pat != null &&
        var.cloudbuildv2_repository_config.github_app_id != null &&
        var.cloudbuildv2_repository_config.gitlab_read_authorizer_credential == null &&
        var.cloudbuildv2_repository_config.gitlab_authorizer_credential == null
        ) : var.cloudbuildv2_repository_config.repo_type == "GITLABv2" ? (
        var.cloudbuildv2_repository_config.github_pat == null &&
        var.cloudbuildv2_repository_config.github_app_id == null &&
        var.cloudbuildv2_repository_config.gitlab_read_authorizer_credential != null &&
        var.cloudbuildv2_repository_config.gitlab_authorizer_credential != null
      ) : var.cloudbuildv2_repository_config.repo_type == "CSR" ? true : false
    )
    error_message = "You must specify a valid repo_type ('GITHUBv2', 'GITLABv2', or 'CSR'). For 'GITHUBv2', all 'github_' prefixed variables must be defined and no 'gitlab_' prefixed variables should be defined. For 'GITLABv2', all 'gitlab_' prefixed variables must be defined and no 'github_' prefixed variables should be defined."
  }
}

