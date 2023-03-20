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

variable "parent_type" {
  description = "Type of the parent resource. valid values are `organization`, `folder`, and `project`."
  type        = string

  validation {
    condition     = contains(["organization", "folder", "project"], var.parent_type)
    error_message = "For parent_type only `organization`, `folder`, and `project` are valid."
  }
}

variable "parent_id" {
  description = "ID of the parent resource."
  type        = string
}

variable "roles" {
  description = "Roles to remove all members in the parent resource."
  type        = list(string)
}
