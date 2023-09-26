variable "tfe_token" {
  description = " The token used to authenticate with Terraform Cloud. See https://registry.terraform.io/providers/hashicorp/tfe/latest/docs#authentication"
  type        = string
  sensitive   = true
}