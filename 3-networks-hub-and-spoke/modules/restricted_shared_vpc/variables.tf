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

variable "access_context_manager_policy_id" {
  type        = number
  description = "The id of the default Access Context Manager policy. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format=\"value(name)\"`."
}

variable "project_id" {
  type        = string
  description = "Project ID for Restricted Shared VPC."
}

variable "project_number" {
  type        = number
  description = "Project number for Restricted Shared VPC. It is the project INSIDE the regular service perimeter."
}

variable "dns_hub_project_id" {
  type        = string
  description = "The DNS hub project ID"
}

variable "restricted_net_hub_project_id" {
  type        = string
  description = "The restricted net hub project ID"
  default     = ""
}

variable "restricted_net_hub_project_number" {
  type        = string
  description = "The restricted net hub project number"
  default     = ""
}

variable "mode" {
  type        = string
  description = "Network deployment mode, should be set to `hub` or `spoke` when `enable_hub_and_spoke` architecture chosen, keep as `null` otherwise."
  default     = null
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization."
}

variable "nat_enabled" {
  type        = bool
  description = "Toggle creation of NAT cloud router."
  default     = false
}

variable "nat_bgp_asn" {
  type        = number
  description = "BGP ASN for NAT cloud routes. If NAT is enabled this variable value must be a value in ranges [64512..65534] or [4200000000..4294967294]."
  default     = 64512
}

variable "nat_num_addresses_region1" {
  type        = number
  description = "Number of external IPs to reserve for region 1 Cloud NAT."
  default     = 2
}

variable "nat_num_addresses_region2" {
  type        = number
  description = "Number of external IPs to reserve for region 2 Cloud NAT."
  default     = 2
}

variable "bgp_asn_subnet" {
  type        = number
  description = "BGP ASN for Subnets cloud routers."
}

variable "default_region1" {
  type        = string
  description = "First subnet region. The shared vpc modules only configures two regions."
}

variable "default_region2" {
  type        = string
  description = "Second subnet region. The shared vpc modules only configures two regions."
}

variable "subnets" {
  type = list(object({
    subnet_name                      = string
    subnet_ip                        = string
    subnet_region                    = string
    subnet_private_access            = optional(string, "false")
    subnet_private_ipv6_access       = optional(string)
    subnet_flow_logs                 = optional(string, "false")
    subnet_flow_logs_interval        = optional(string, "INTERVAL_5_SEC")
    subnet_flow_logs_sampling        = optional(string, "0.5")
    subnet_flow_logs_metadata        = optional(string, "INCLUDE_ALL_METADATA")
    subnet_flow_logs_filter          = optional(string, "true")
    subnet_flow_logs_metadata_fields = optional(list(string), [])
    description                      = optional(string)
    purpose                          = optional(string)
    role                             = optional(string)
    stack_type                       = optional(string)
    ipv6_access_type                 = optional(string)
  }))
  description = "The list of subnets being created"
  default     = []
}

variable "secondary_ranges" {
  type        = map(list(object({ range_name = string, ip_cidr_range = string })))
  description = "Secondary ranges that will be used in some of the subnets"
  default     = {}
}

variable "dns_enable_inbound_forwarding" {
  type        = bool
  description = "Toggle inbound query forwarding for VPC DNS."
  default     = true
}

variable "dns_enable_logging" {
  type        = bool
  description = "Toggle DNS logging for VPC DNS."
  default     = true
}

variable "firewall_enable_logging" {
  type        = bool
  description = "Toggle firewall logging for VPC Firewalls."
  default     = true
}

variable "domain" {
  type        = string
  description = "The DNS name of peering managed zone, for instance 'example.com.'"
}

variable "private_service_cidr" {
  type        = string
  description = "CIDR range for private service networking. Used for Cloud SQL and other managed services."
  default     = null
}

variable "private_service_connect_ip" {
  type        = string
  description = "Internal IP to be used as the private service connect endpoint."
}

variable "windows_activation_enabled" {
  type        = bool
  description = "Enable Windows license activation for Windows workloads."
  default     = false
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
  description = "List of services to restrict in a dry-run perimeter."
}

variable "enable_all_vpc_internal_traffic" {
  type        = bool
  description = "Enable firewall policy rule to allow internal traffic (ingress and egress)."
  default     = false
}

variable "enable_transitivity_traffic" {
  type        = bool
  description = "Enable a firewall policy rule to allow traffic between Hub and Spokes (ingress only)."
  default     = true
}

variable "enforce_vpcsc" {
  description = "Enable the enforced mode for VPC Service Controls. It is not recommended to enable VPC-SC on the first run deploying your foundation. Review [best practices for enabling VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/enable), then only enforce the perimeter after you have analyzed the access patterns in your dry-run perimeter and created the necessary exceptions for your use cases."
  type        = bool
  default     = false
}

variable "egress_policies" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) to use in an enforced perimeter. Each list object has a `from` and `to` value that describes egress_from and egress_to.\n\nExample: `[{ from={ identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "egress_policies_dry_run" {
  description = "A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) to use in a dry-run perimeter. Each list object has a `from` and `to` value that describes egress_from and egress_to.\n\nExample: `[{ from={ identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "ingress_policies" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference) to use in an enforced perimeter. Each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}

variable "ingress_policies_dry_run" {
  description = "A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference) to use in a dry-run perimeter. Each list object has a `from` and `to` value that describes ingress_from and ingress_to.\n\nExample: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type=\"ID_TYPE\" }, to={ resources=[], operations={ \"SRV_NAME\"={ OP_TYPE=[] }}}}]`\n\nValid Values:\n`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`\n`SRV_NAME` = \"`*`\" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)\n`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions)"
  type = list(object({
    from = any
    to   = any
  }))
  default = []
}
