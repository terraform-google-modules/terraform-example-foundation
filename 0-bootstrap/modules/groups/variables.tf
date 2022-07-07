/**
 * Copyright 2022 Google LLC
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

variable "create_groups_holder" {
  description = "Contain the details of the Groups to be created"
  type = object({
    create_groups = bool
    required_groups = object({
      group_org_admins           = string
      group_billing_admins       = string
      billing_data_users         = string
      audit_data_users           = string
      monitoring_workspace_users = string
    })
    optional_groups = object({
      gcp_platform_viewer      = string
      gcp_security_reviewer    = string
      gcp_network_viewer       = string
      gcp_scc_admin            = string
      gcp_global_secrets_admin = string
      gcp_audit_viewer         = string
    })
  })
  default = {
    create_groups = false
    required_groups = {
      group_org_admins           = ""
      group_billing_admins       = ""
      billing_data_users         = ""
      audit_data_users           = ""
      monitoring_workspace_users = ""
    }
    optional_groups = {
      gcp_platform_viewer      = ""
      gcp_security_reviewer    = ""
      gcp_network_viewer       = ""
      gcp_scc_admin            = ""
      gcp_global_secrets_admin = ""
      gcp_audit_viewer         = ""
    }
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.required_groups.group_org_admins)) : true
    error_message = "The group group_org_admins is invalid. Only valid format emails Required Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.required_groups.group_billing_admins)) : true
    error_message = "The group group_billing_admins is invalid. Only valid format emails Required Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.required_groups.billing_data_users)) : true
    error_message = "The group billing_data_users is invalid. Only valid format emails Required Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.required_groups.audit_data_users)) : true
    error_message = "The group audit_data_users is invalid. Only valid format emails Required Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.required_groups.monitoring_workspace_users)) : true
    error_message = "The group monitoring_workspace_users is invalid. Only valid format emails Required Groups creation."
  }


  validation {
    condition     = var.create_groups_holder.create_groups == true ? (var.create_groups_holder.optional_groups.gcp_platform_viewer == "" ? true : can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.optional_groups.gcp_platform_viewer))) : true
    error_message = "The group gcp_platform_viewer is invalid. Only valid format emails or empty strings are valid for Optional Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? (var.create_groups_holder.optional_groups.gcp_security_reviewer == "" ? true : can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.optional_groups.gcp_security_reviewer))) : true
    error_message = "The group gcp_security_reviewer is invalid. Only valid format emails or empty strings are valid for Optional Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? (var.create_groups_holder.optional_groups.gcp_network_viewer == "" ? true : can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.optional_groups.gcp_network_viewer))) : true
    error_message = "The group gcp_network_viewer is invalid. Only valid format emails or empty strings are valid for Optional Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? (var.create_groups_holder.optional_groups.gcp_scc_admin == "" ? true : can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.optional_groups.gcp_scc_admin))) : true
    error_message = "The group gcp_scc_admin is invalid. Only valid format emails or empty strings are valid for Optional Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? (var.create_groups_holder.optional_groups.gcp_global_secrets_admin == "" ? true : can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.optional_groups.gcp_global_secrets_admin))) : true
    error_message = "The group gcp_global_secrets_admin is invalid. Only valid format emails or empty strings are valid for Optional Groups creation."
  }

  validation {
    condition     = var.create_groups_holder.create_groups == true ? (var.create_groups_holder.optional_groups.gcp_audit_viewer == "" ? true : can(regex("[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?[.])+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?", var.create_groups_holder.optional_groups.gcp_audit_viewer))) : true
    error_message = "The group gcp_audit_viewer is invalid. Only valid format emails or empty strings are valid for Optional Groups creation."
  }

}

variable "customer_id" {
  type = string
}

variable "initial_group_config" {
  type    = string
  default = "WITH_INITIAL_OWNER"
}
