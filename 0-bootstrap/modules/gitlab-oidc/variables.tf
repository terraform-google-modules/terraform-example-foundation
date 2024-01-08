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
  description = "The project id to create Workload Identity Pool"
}

variable "service_list" {
  description = "Google Cloud APIs required for the project"
  type        = list(string)
  default = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "sts.googleapis.com",
    "iamcredentials.googleapis.com"
  ]
}

variable "pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
}

variable "pool_display_name" {
  type        = string
  description = "Workload Identity Pool display name"
  default     = null
}

variable "pool_description" {
  type        = string
  description = "Workload Identity Pool description"
  default     = "Workload Identity Pool managed by Terraform"
}

variable "provider_id" {
  type        = string
  description = "Workload Identity Pool Provider id"
}

variable "issuer_uri" {
  type        = string
  description = "Workload Identity Pool Issuer URL"
  default     = "https://gitlab.com"
}

variable "provider_display_name" {
  type        = string
  description = "Workload Identity Pool Provider display name"
  default     = null
}

variable "provider_description" {
  type        = string
  description = "Workload Identity Pool Provider description"
  default     = "Workload Identity Pool Provider managed by Terraform"
}

variable "attribute_condition" {
  type        = string
  description = <<-EOF
  Workload Identity Pool Provider attribute condition expression
  For more info please see
  https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
  EOF
  default     = null
}

variable "attribute_mapping" {
  type        = map(any)
  description = <<-EOF
  Workload Identity Pool Provider attribute mapping
  For more info please see:
  https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider
  https://docs.gitlab.com/ee/ci/secrets/id_token_authentication.html#token-payload
  EOF
  default = {
    # Principal IAM
    "google.subject" = "assertion.sub"
    # standard claims
    "attribute.sub" = "attribute.sub"
    "attribute.iss" = "attribute.iss"
    "attribute.aud" = "attribute.aud"
    "attribute.exp" = "attribute.exp"
    "attribute.nbf" = "attribute.nbf"
    "attribute.iat" = "attribute.iat"
    "attribute.jti" = "attribute.jti"
    # GitLab custom claims
    "attribute.namespace_id"   = "assertion.namespace_id"
    "attribute.namespace_path" = "assertion.namespace_path"
    "attribute.project_id"     = "assertion.project_id"
    "attribute.project_path"   = "assertion.project_path"
    "attribute.user_id"        = "assertion.user_id"
    "attribute.user_login"     = "assertion.user_login"
    "attribute.user_email"     = "assertion.user_email"
  }
}

variable "allowed_audiences" {
  type        = list(string)
  description = "Workload Identity Pool Provider allowed audiences."
  default     = []
}

variable "sa_mapping" {
  type = map(object({
    sa_name   = string
    attribute = string
  }))
  description = <<-EOF
    Service Account resource names and corresponding WIF provider attributes.
    If attribute is set to `*` all identities in the pool are granted access to SAs
  EOF
  default     = {}
}
