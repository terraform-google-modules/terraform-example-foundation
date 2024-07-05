variable "project_id" {
  description = "The project id to create the secret and assign cloudbuild service account permissions."
  type        = string
}

variable "github_pat" {
  description = "The Github Personal Access Token."
  type        = string
}

variable "secret_id" {
  description = "The secret id for the secret."
  type        = string
  default     = "terraform-workspace-github-pat"
}
