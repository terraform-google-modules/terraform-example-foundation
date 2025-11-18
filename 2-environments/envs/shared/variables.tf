/**
 * Copyright 2021 Google LLC
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

variable "remote_state_bucket" {
  description = "Backend bucket to load Terraform Remote State Data from previous steps."
  type        = string
}

variable "tfc_org_name" {
  description = "Name of the TFC organization"
  type        = string
  default     = ""
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


variable "is_environment_level_1" {
  description = "Are the environment folders on the top level"
  type = bool
}

variable "level_1_folders" {
  description = "The top level folders to be added to the hierarchy"
  type        = list(map(string))
  default     = []
}

variable "level_2_folders" {
  description = "The second level folders to be added to each of the top level folders"
  type        = list(map(string))
  default     = []
}

variable "assured_workload_enabled" {
  description = "Enable Assured Workload for production project"
  type = bool
}

variable "assured_workload_region" {
  description = "Region for Assured Workload"
  type = string
}
