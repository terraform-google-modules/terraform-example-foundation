/**
 * Copyright 2026 Google LLC
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

variable "project_id" {
  type        = string
  description = "Project ID to create the routers."
}

variable "vpc_name" {
  type        = string
  description = "Label to identify the VPC associated with VPC that will use the Routers."
}

variable "router_config" {
  description = <<EOT
Cloud Routers configuration map containing router definitions.

Top-level attributes:
  - bgp_asn:              Default BGP Autonomous System Number (ASN) for the Cloud Routers.
  - advertised_groups:    (Optional) Default list of advertised groups (defaults to ["ALL_SUBNETS"]).
  - advertised_ip_ranges: (Optional) Default list of custom IP ranges to advertise.
  - routers:              Map of Cloud Router objects keyed by a unique identifier.

Router attributes (map values):
  - region:    Google Cloud region where the Cloud Router resides.
  - cr_suffix: Suffix used for router naming (e.g., 'cr1', 'cr2').
EOT

  type = object({
    bgp_asn           = number
    advertised_groups = optional(list(string), ["ALL_SUBNETS"])
    advertised_ip_ranges = optional(list(object({
      range       = string
      description = optional(string)
    })), [])
    routers = map(object({
      region    = string
      cr_suffix = string
    }))
  })
}
