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

variable "attribute_condition" {
  type        = string
  description = "Workload Identity Pool Provider attribute condition expression. [More info](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider#attribute_condition)"
  default     = null
}

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "default_region" {
  description = "Default region to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "default_region_2" {
  description = "Secondary default region to create resources where applicable."
  type        = string
  default     = "us-west1"
}

variable "default_region_gcs" {
  description = "Case-Sensitive default region to create gcs resources where applicable."
  type        = string
  default     = "US"
}

variable "default_region_kms" {
  description = "Secondary default region to create kms resources where applicable."
  type        = string
  default     = "us"
}

variable "parent_folder" {
  description = "Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist."
  type        = string
  default     = ""
}

variable "org_policy_admin_role" {
  description = "Additional Org Policy Admin role for admin group. You can use this for testing purposes."
  type        = bool
  default     = false
}

variable "project_prefix" {
  description = "Name prefix to use for projects created. Should be the same in all steps. Max size is 3 characters."
  type        = string
  default     = "prj"
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created. Should be the same in all steps."
  type        = string
  default     = "fldr"
}

variable "bucket_prefix" {
  description = "Name prefix to use for state bucket created."
  type        = string
  default     = "bkt"
}

variable "bucket_force_destroy" {
  description = "When deleting a bucket, this boolean option will delete all contained objects. If false, Terraform will fail to delete buckets which contain objects."
  type        = bool
  default     = false
}

variable "bucket_tfstate_kms_force_destroy" {
  description = "When deleting a bucket, this boolean option will delete the KMS keys used for the Terraform state bucket."
  type        = bool
  default     = false
}

variable "project_deletion_policy" {
  description = "The deletion policy for the project created."
  type        = string
  default     = "PREVENT"
}

variable "folder_deletion_protection" {
  description = "Prevent Terraform from destroying or recreating the folder."
  type        = string
  default     = true
}

variable "workflow_deletion_protection" {
  description = "Whether Terraform will be prevented from destroying a workflow. When the field is set to true or unset in Terraform state, a `terraform apply` or `terraform destroy` that would delete the workflow will fail. When the field is set to false, deleting the workflow is allowed."
  type        = bool
  default     = true
}

/* ----------------------------------------
    Bootstrap access model
   ---------------------------------------- */
variable "bootstrap_admin_members" {
  description = <<EOT
  Generic IAM members to treat as bootstrap administrators.
  Use fully-qualified member strings such as:
  - user:alice@example.com
  - serviceAccount:sa-bootstrap@example-project.iam.gserviceaccount.com
  - group:platform-admins@example.com
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for member in var.bootstrap_admin_members : can(regex("^(group|serviceAccount|user):", member))])
    error_message = "bootstrap_admin_members entries must be fully-qualified IAM members prefixed with group:, serviceAccount:, or user:."
  }
}

variable "billing_admin_members" {
  description = <<EOT
  Generic IAM members to treat as billing administrators.
  Use fully-qualified member strings such as:
  - user:alice@example.com
  - serviceAccount:sa-bootstrap@example-project.iam.gserviceaccount.com
  - group:billing-admins@example.com
  EOT
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for member in var.billing_admin_members : can(regex("^(group|serviceAccount|user):", member))])
    error_message = "billing_admin_members entries must be fully-qualified IAM members prefixed with group:, serviceAccount:, or user:."
  }
}
