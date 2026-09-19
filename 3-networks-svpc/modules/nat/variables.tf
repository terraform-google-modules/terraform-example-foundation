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
  description = "Project ID for VPC."
  type        = string
}

variable "vpc_name" {
  description = "The name of the network. To be used to compose names of resources like `cr-{vpc_name}`"
  type        = string
}

variable "network_self_link" {
  type        = string
  description = "Target Network self link."
}

variable "resource_code" {
  type        = string
  description = "Standardized grouping code used to categorize resources by their environment (e.g., 'p' for production) or their architectural/topology role (e.g., 'h' for hub, 's' for spoke). Used as an infix in resource names (e.g., cr-p-svpc-us-central1-nat-router)"
}

variable "nat_config" {
  description = <<-EOT
    Configuration for Cloud NAT and underlying Cloud Routers.
    Attributes:
    - egress_tags: Network tags used for routing internet egress traffic (default: ["egress-internet"]).
    - bgp_asn: The BGP Autonomous System Number assigned to the Cloud Router (default: 64512).
    - regions: Defines which regions get a NAT router.
      - name: The GCP region name (e.g., "us-central1") where the router and NAT will be deployed.
      - num_addresses: The number of static external IP addresses to manually allocate and assign to the NAT gateway in this region (default: 2).
  EOT
  type = object({
    egress_tags = optional(list(string), ["egress-internet"])
    bgp_asn     = optional(number, 64512)
    regions = optional(list(object({
      name          = string
      num_addresses = optional(number, 2)
    })))
  })
  default = {}
}
