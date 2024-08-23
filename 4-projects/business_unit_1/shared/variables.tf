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
  default     = "us-central1"
}

variable "project_budget" {
  description = <<EOT
  Budget configuration.
  budget_amount: The amount to use as the budget.
  alert_spent_percents: A list of percentages of the budget to alert on when threshold is exceeded.
  alert_pubsub_topic: The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}`.
  alert_spend_basis: The type of basis used to determine if spend has passed the threshold. Possible choices are `CURRENT_SPEND` or `FORECASTED_SPEND` (default).
  EOT
  type = object({
    budget_amount        = optional(number, 1000)
    alert_spent_percents = optional(list(number), [1.2])
    alert_pubsub_topic   = optional(string, null)
    alert_spend_basis    = optional(string, "FORECASTED_SPEND")
  })
  default = {}
}

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
  default     = ""
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
