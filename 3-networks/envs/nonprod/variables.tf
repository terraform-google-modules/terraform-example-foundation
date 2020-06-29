/**
 * Copyright 2020 Google LLC
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
  type        = string
  description = "Organization ID"
}

variable "terraform_service_account" {
  type        = string
  description = "Service account email of the account to impersonate to run Terraform."
}

variable "nat_region" {
  type        = string
  description = "NAT region for the shared vpc module."
}

variable "subnet_region1" {
  type        = string
  description = "First subnet region. The shared vpc modules only configures exactly two regions."
}

variable "subnet_region2" {
  type        = string
  description = "Second subnet region. The shared vpc modules only configures exactly two regions."
}
