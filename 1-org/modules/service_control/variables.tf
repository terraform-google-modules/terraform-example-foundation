/**
 * Copyright 2025 Google LLC
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

variable "access_context_manager_policy_id" {
  type        = number
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
}

variable "members" {
  type        = list(string)
  description = "An allowed list of members (users, service accounts) for an access level in an enforced perimeter. The signed-in identity originating the request must be a part of one of the provided members. If not specified, a request may come from any user (logged in/not logged in, etc.). Formats: user:{emailid}, serviceAccount:{emailid}"
}

variable "members_dry_run" {
  type        = list(string)
  description = "An allowed list of members (users, service accounts) for an access level in a dry run perimeter. The signed-in identity originating the request must be a part of one of the provided members. If not specified, a request may come from any user (logged in/not logged in, etc.). Formats: user:{emailid}, serviceAccount:{emailid}"
}


variable "restricted_services" {
  type        = list(string)
  description = "List of services to restrict in an enforced perimeter."
}

variable "restricted_services_dry_run" {
  type        = list(string)
  description = "List of services to restrict in an enforced perimeter."
}

variable "enforce_vpcsc" {
  description = "Enable the enforced mode for VPC Service Controls. It is not recommended to enable VPC-SC on the first run deploying your foundation. Review [best practices for enabling VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/enable), then only enforce the perimeter after you have analyzed the access patterns in your dry-run perimeter and created the necessary exceptions for your use cases."
  type        = bool
  default     = false
}

variable "ingress_policies_dry_run_map" {
  description = "Map of ingress policies for dry-run perimeter. Map key is the Terraform state key."
  type = map(object({
    title = optional(string, null)
    from = object({
      sources = optional(object({
        resources     = optional(list(string), [])
        access_levels = optional(list(string), [])
      }), {}),
      identity_type = optional(string, null)
      identities    = optional(list(string), null)
    })
    to = object({
      operations = optional(map(object({
        methods     = optional(list(string), [])
        permissions = optional(list(string), [])
      })), {}),
      roles     = optional(list(string), null)
      resources = optional(list(string), ["*"])
    })
  }))
  default = {}
}

variable "egress_policies_dry_run_map" {
  description = "Map of egress policies for dry-run perimeter. Map key is the Terraform state key."
  type = map(object({
    title = optional(string, null)
    from = object({
      sources = optional(object({
        resources     = optional(list(string), [])
        access_levels = optional(list(string), [])
      }), {}),
      identity_type = optional(string, null)
      identities    = optional(list(string), null)
    })
    to = object({
      operations = optional(map(object({
        methods     = optional(list(string), [])
        permissions = optional(list(string), [])
      })), {}),
      roles              = optional(list(string), null)
      resources          = optional(list(string), ["*"])
      external_resources = optional(list(string), [])
    })
  }))
  default = {}
}

variable "ingress_policies_map" {
  description = "Map of ingress policies for enforced perimeter. Map key is the Terraform state key."
  type = map(object({
    title = optional(string, null)
    from = object({
      sources = optional(object({
        resources     = optional(list(string), [])
        access_levels = optional(list(string), [])
      }), {}),
      identity_type = optional(string, null)
      identities    = optional(list(string), null)
    })
    to = object({
      operations = optional(map(object({
        methods     = optional(list(string), [])
        permissions = optional(list(string), [])
      })), {}),
      roles     = optional(list(string), null)
      resources = optional(list(string), ["*"])
    })
  }))
  default = {}
}

variable "egress_policies_map" {
  description = "Map of egress policies for enforced perimeter. Map key is the Terraform state key."
  type = map(object({
    title = optional(string, null)
    from = object({
      sources = optional(object({
        resources     = optional(list(string), [])
        access_levels = optional(list(string), [])
      }), {}),
      identity_type = optional(string, null)
      identities    = optional(list(string), null)
    })
    to = object({
      operations = optional(map(object({
        methods     = optional(list(string), [])
        permissions = optional(list(string), [])
      })), {}),
      roles              = optional(list(string), null)
      resources          = optional(list(string), ["*"])
      external_resources = optional(list(string), [])
    })
  }))
  default = {}
}

variable "resources" {
  description = "A list of GCP resources that are inside of the service perimeter. Currently only projects and VPC networks are allowed."
  type        = list(string)
  default     = []
}

variable "resource_keys" {
  description = "A list of keys to use for the Terraform state. The order should correspond to var.resources and the keys must not be dynamically computed. If `null`, var.resources will be used as keys."
  type        = list(string)
  default     = null
}

variable "resources_dry_run" {
  description = "A list of GCP resources that are inside of the service perimeter. Currently only projects and VPC networks are allowed. If set, a dry-run policy will be set."
  type        = list(string)
  default     = []
}

variable "resource_keys_dry_run" {
  description = "A list of keys to use for the Terraform state. The order should correspond to var.resources_dry_run and the keys must not be dynamically computed. If `null`, var.resources_dry_run will be used as keys."
  type        = list(string)
  default     = null
}

variable "vpc_sc_propagation_sleep_duration" {
  description = "The duration to wait for VPC Service Controls propagation (e.g., 60s, 2m)."
  type        = string
  default     = "60s"
}
