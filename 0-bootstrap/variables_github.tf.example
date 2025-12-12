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

/* ----------------------------------------
    Specific to github_bootstrap
   ---------------------------------------- */

# Un-comment github_bootstrap and its outputs if you want to use GitHub Actions instead of Cloud Build
variable "gh_repos" {
  description = <<EOT
  Configuration for the GitHub Repositories to be used to deploy the Terraform Example Foundation stages.
  owner: The owner of the repositories. An user or an organization.
  bootstrap: The repository to host the code of the bootstrap stage.
  organization: The repository to host the code of the organization stage.
  environments: The repository to host the code of the environments stage.
  networks: The repository to host the code of the networks stage.
  projects: The repository to host the code of the projects stage.
  EOT
  type = object({
    owner        = string,
    bootstrap    = string,
    organization = string,
    environments = string,
    networks     = string,
    projects     = string,
  })
}

variable "gh_token" {
  description = "A fine-grained personal access token for the user or organization. See https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token"
  type        = string
  sensitive   = true
}
