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

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "project_id" {
  description = "The Project ID where the resources will be created"
  type        = string
}

variable "location" {
  description = "Default location to create resources where applicable."
  type        = string
  default     = "us-central1"
}

variable "encryption_key" {
  description = "The KMS Key to Encrypt Artifact Registry repository, Cloud Storage Bucket and Pub/Sub."
  type        = string
}

variable "labels" {
  description = "Labels to be assigned to resources."
  type        = map(any)
  default     = {}
}

variable "impersonate_sa_email" {
  description = "The Service Account email who will execute terraform code."
  type        = string
}

variable "roles_to_monitor" {
  description = "List of roles that will trigger a notification if granted to an identity in an update in the organization IAM Policy."
  type        = list(string)
  default = [
    "roles/owner",
    "roles/editor",
    "roles/resourcemanager.organizationAdmin",
    "roles/compute.networkAdmin",
    "roles/compute.orgFirewallPolicyAdmin"
  ]
}

variable "scc_random_suffix" {
  description = "Adds a suffix of 4 random characters to the `scc_source` name."
  type        = bool
  default     = false
}
