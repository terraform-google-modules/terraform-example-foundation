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

variable "name" {
  description = "Hierarchical policy name"
  type        = string
}

variable "parent" {
  description = "Where the firewall policy will be created (can be organizations/{organization_id} or folders/{folder_id})"
  type        = string
}

variable "rules" {
  description = "Firewall rules to add to the policy"
  type = map(object({
    description             = string
    direction               = string
    action                  = string
    priority                = number
    ranges                  = list(string)
    ports                   = map(list(string))
    target_service_accounts = list(string)
    target_resources        = list(string)
    logging                 = bool
  }))
  default = {}
}

variable "associations" {
  description = "Resources to associate the policy to"
  type        = list(string)
}
