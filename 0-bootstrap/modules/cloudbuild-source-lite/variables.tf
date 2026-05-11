variable "org_id" {
  description = "GCP Organization ID."
  type        = string
}

variable "folder_id" {
  description = "The folder ID where the Cloud Build project will be created."
  type        = string
  default     = ""
}

variable "project_id" {
  description = "Cloud Build project ID."
  type        = string
}

variable "project_deletion_policy" {
  description = "The deletion policy for the project created."
  type        = string
  default     = "PREVENT"
}

variable "project_labels" {
  description = "Labels to apply to the project."
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Location for the Cloud Build bucket."
  type        = string
}

variable "buckets_force_destroy" {
  description = "Whether to force-destroy Cloud Build buckets."
  type        = bool
  default     = false
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "admin_members" {
  description = "IAM members to grant Cloud Build project administration permissions."
  type        = list(string)
  default     = []
}

variable "activate_apis" {
  description = "List of APIs to enable in the Cloud Build project."
  type        = list(string)
  default     = []
}

variable "cloud_source_repos" {
  description = "List of Cloud Source Repositories to create."
  type        = list(string)
  default     = []
}
