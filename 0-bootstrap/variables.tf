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

variable "universe_prefix" {
  description = "Universe_prefix is the universe short name prefix to prepend to the project ID (e.g., 'eu0'). A colon (:) is automatically appended to the project ID, and a hyphen (-) is used for the state bucket name."
  type        = string
  default     = ""

  validation {
    condition     = var.universe_prefix == "" || can(regex("^[a-z0-9]+$", var.universe_prefix))
    error_message = "The universe_prefix variable must be empty or contain only lowercase alphanumeric characters."
  }
}

variable "universe_domain" {
  description = "The universe domain to use for Google Cloud APIs. This defines the API endpoint boundary for your deployment. The default is 'googleapis.com' for the standard public Google Cloud. Modify this value if you are deploying to isolated environments like Google Distributed Cloud (GDC), Trusted Partner Cloud (TPC), or other sovereign cloud environments."
  type        = string
  default     = "googleapis.com"

  validation {
    condition     = var.universe_domain != null && length(trimspace(coalesce(var.universe_domain, ""))) > 0
    error_message = "The universe_domain variable cannot be null or an empty string."
  }
}

variable "pkg_dev_domain" {
  description = "Domain for Artifact Registry. Change if using a custom universe_domain."
  type        = string
  default     = "pkg.dev"

  validation {
    condition     = var.pkg_dev_domain != null && length(trimspace(coalesce(var.pkg_dev_domain, ""))) > 0
    error_message = "The pkg_dev_domain variable cannot be null or an empty string."
  }
}

variable "enable_gcr_dns" {
  description = "Enable DNS zone creation for legacy gcr.io. Set to false for GDC/TPC environments where Container Registry is not available."
  type        = bool
  default     = true
}

variable "available_universe_services" {
  description = "A general configuration object to toggle available services in the universe. All services default to true if omitted."
  type = object({
    billing_budget     = optional(bool, true)
    security_center    = optional(bool, true)
    service_networking = optional(bool, true)
    storage_api        = optional(bool, true)
    admin              = optional(bool, true)
    appengine          = optional(bool, true)
    assured_workloads  = optional(bool, true)
    cloud_build        = optional(bool, true)
    cloud_asset        = optional(bool, true)
    secret_manager     = optional(bool, true)
    multi_region       = optional(bool, true)
  })
  default = {}
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
    Specific to Groups creation
   ---------------------------------------- */
variable "groups" {
  description = <<EOT
  Contains the details of the IAM groups to be created or used for permissions.
  The group identifiers inside 'required_groups' and 'optional_groups' accept either standard Google Group email addresses or principalSet URIs (e.g., 'principalSet://...').
  Note: If providing principalSet URIs, ensure that 'create_required_groups' and 'create_optional_groups' are set to false, as principalSets are external identities and cannot be created as Google Groups.
  EOT
  type = object({
    create_required_groups = optional(bool, false)
    create_optional_groups = optional(bool, false)
    billing_project        = optional(string, null)
    required_groups = object({
      group_org_admins     = string
      group_billing_admins = string
      billing_data_users   = string
      audit_data_users     = string
    })
    optional_groups = optional(object({
      gcp_security_reviewer    = optional(string, "")
      gcp_network_viewer       = optional(string, "")
      gcp_scc_admin            = optional(string, "")
      gcp_global_secrets_admin = optional(string, "")
      gcp_kms_admin            = optional(string, "")
    }), {})
  })

  # Prevent trying to create a principalSet as if it were a Google Group
  validation {
    condition = (
      (var.groups.create_required_groups != true || !anytrue([
        for v in values(var.groups.required_groups) : try(startswith(v, "principalSet://"), false)
      ]))
      &&
      (var.groups.create_optional_groups != true || !anytrue([
        for v in values(var.groups.optional_groups != null ? var.groups.optional_groups : {}) : try(startswith(v, "principalSet://"), false)
      ]))
    )
    error_message = "You cannot set create_required_groups or create_optional_groups to true if any of the provided group variables contain a 'principalSet://' URI. principalSets are external identities and cannot be created as Google Groups."
  }

  validation {
    condition     = var.groups.create_required_groups || var.groups.create_optional_groups ? var.groups.billing_project != null : true
    error_message = "A billing_project must be passed to use the automatic group creation."
  }

  validation {
    condition     = var.groups.required_groups.group_org_admins != ""
    error_message = "The group_org_admins is invalid, it must be a valid email or principalSet URI."
  }

  validation {
    condition     = var.groups.required_groups.group_billing_admins != ""
    error_message = "The group_billing_admins is invalid, it must be a valid email or principalSet URI."
  }

  validation {
    condition     = var.groups.required_groups.billing_data_users != ""
    error_message = "The billing_data_users is invalid, it must be a valid email or principalSet URI."
  }

  validation {
    condition     = var.groups.required_groups.audit_data_users != ""
    error_message = "The audit_data_users is invalid, it must be a valid email or principalSet URI."
  }
}

variable "initial_group_config" {
  description = "Define the group configuration when it is initialized. Valid values are: WITH_INITIAL_OWNER, EMPTY and INITIAL_GROUP_CONFIG_UNSPECIFIED."
  type        = string
  default     = "WITH_INITIAL_OWNER"
}
