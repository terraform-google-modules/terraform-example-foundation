/* ----------------------------------------
    Specific to tfc_bootstrap
   ---------------------------------------- */

# Un-comment tfc_bootstrap and its outputs if you want to use Terraform Cloud instead of Cloud Build
variable "vcs_repos" {
  description = <<EOT
  Configuration for the Terraform Cloud VCS Repositories to be used to deploy the Terraform Example Foundation stages.
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
    app-infra    = string,
  })
}

variable "tfc_token" {
  description = " The token used to authenticate with Terraform Cloud. See https://registry.terraform.io/providers/hashicorp/tfe/latest/docs#authentication"
  type        = string
  sensitive   = true
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
}

variable "vcs_api_url" {
  description = "The base URL of your VCS provider's API. (e.g: https://api.github.com)"
  type        = string
}

variable "vcs_http_url" {
  description = "The homepage of your VCS provider. (e.g: https://github.com)"
  type        = string
}

variable "vcs_service_provider" {
  description = "The VCS provider being connected with. (e.g: github, gitlab_hosted). See more valid providers options on: https://registry.terraform.io/providers/hashicorp/tfe/latest/docs/resources/oauth_client#service_provider"
  type        = string
}

# Make clear this description
variable "vcs_oauth_token" {
  description = "The token string of your VCS provider for the user or organization. See https://developer.hashicorp.com/terraform/cloud-docs/api-docs/oauth-clients#create-an-oauth-client"
  type        = string
  sensitive   = true
}
