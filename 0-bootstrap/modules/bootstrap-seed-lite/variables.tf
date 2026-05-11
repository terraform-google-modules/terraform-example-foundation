variable "org_id" {
  description = "GCP Organization ID."
  type        = string
}

variable "folder_id" {
  description = "The folder ID where the seed project will be created."
  type        = string
}

variable "parent_folder" {
  description = "Optional parent folder in the form folders/{id} used for project creator IAM."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "Seed project ID."
  type        = string
}

variable "state_bucket_name" {
  description = "Terraform state bucket name."
  type        = string
}

variable "force_destroy" {
  description = "Whether to force-destroy the state bucket."
  type        = bool
  default     = false
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "bootstrap_admin_members" {
  description = "IAM members to grant bootstrap administration permissions."
  type        = list(string)
  default     = []
}

variable "billing_admin_members" {
  description = "IAM members to grant billing administration permissions."
  type        = list(string)
  default     = []
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
}

variable "org_project_creators" {
  description = "IAM members that should hold Project Creator at the org or parent folder."
  type        = list(string)
  default     = []
}

variable "org_admins_org_iam_permissions" {
  description = "Organization roles to grant bootstrap administrators."
  type        = list(string)
  default     = []
}

variable "project_prefix" {
  description = "Project prefix used when naming KMS resources."
  type        = string
}

variable "encrypt_gcs_bucket_tfstate" {
  description = "Encrypt the Terraform state bucket with KMS."
  type        = bool
  default     = false
}

variable "key_rotation_period" {
  description = "The rotation period of the KMS key."
  type        = string
  default     = null
}

variable "kms_prevent_destroy" {
  description = "Set prevent_destroy on KMS keys."
  type        = bool
  default     = true
}

variable "project_deletion_policy" {
  description = "The deletion policy for the project created."
  type        = string
  default     = "PREVENT"
}

variable "project_labels" {
  description = "Labels to apply to the seed project."
  type        = map(string)
  default     = {}
}

variable "activate_apis" {
  description = "List of APIs to enable in the seed project."
  type        = list(string)
  default     = []
}

variable "sa_org_iam_permissions" {
  description = "Unused compatibility field retained for call-site compatibility."
  type        = list(string)
  default     = []
}
