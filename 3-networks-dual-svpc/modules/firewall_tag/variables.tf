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

variable "project_id" {
  type        = string
  description = "The project ID where the resources will be created."
}

variable "network_name" {
  type        = string
  description = "The network name that will be the purpose of the security tag."
}

variable "network_id" {
  type        = string
  description = "The network ID which the Firewall Policy will be associated."
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization (ex. d)."
}

variable "business_unit" {
  type        = list(string)
  description = "A list of business unit to create the tag values. Default value is a list with one element (value)."
  default     = ["value"]
}
