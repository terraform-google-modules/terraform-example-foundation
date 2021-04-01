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

variable "org_id" {
  description = "The numeric organization id"
}

variable "parent_folder" {
  description = "The folder to deploy in"
}

variable "billing_account" {
  description = "The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ"
}

variable "group_email" {
  description = "The group that will be assigned permissions for testing."
}

variable "terraform_service_account" {
  description = "The SA that will be used for creating projects."
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
}
