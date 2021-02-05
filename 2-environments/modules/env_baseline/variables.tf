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

variable "env" {
  description = "The environment to prepare (ex. development)"
  type        = string
}

variable "environment_code" {
  type        = string
  description = "A short form of the folder level resources (environment) within the Google Cloud organization (ex. d)."
}

variable "parent_id" {
  description = "The parent folder or org for environments"
  type        = string
}

variable "org_id" {
  description = "The organization id for the associated services"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "terraform_service_account" {
  description = "Service account email of the account to impersonate to run Terraform."
  type        = string
}

variable "monitoring_workspace_users" {
  description = "Google Workspace or Cloud Identity group that have access to Monitoring Workspaces."
  type        = string
}

variable "base_network_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the base networks project"
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "base_network_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the base networks project"
  type        = string
  default     = null
}

variable "base_network_project_budget_amount" {
  description = "The amount to use as the budget for the base networks project"
  type        = number
  default     = 1000
}

variable "restricted_network_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the restricted networks project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "restricted_network_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the restricted networks project"
  type        = string
  default     = null
}

variable "restricted_network_project_budget_amount" {
  description = "The amount to use as the budget for the restricted networks project."
  type        = number
  default     = 1000
}

variable "monitoring_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the monitoring project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "monitoring_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the monitoring project."
  type        = string
  default     = null
}

variable "monitoring_project_budget_amount" {
  description = "The amount to use as the budget for the monitoring project."
  type        = number
  default     = 1000
}

variable "secret_project_alert_spent_percents" {
  description = "A list of percentages of the budget to alert on when threshold is exceeded for the secrets project."
  type        = list(number)
  default     = [0.5, 0.75, 0.9, 0.95]
}

variable "secret_project_alert_pubsub_topic" {
  description = "The name of the Cloud Pub/Sub topic where budget related messages will be published, in the form of `projects/{project_id}/topics/{topic_id}` for the secrets project."
  type        = string
  default     = null
}

variable "secret_project_budget_amount" {
  description = "The amount to use as the budget for the secrets project."
  type        = number
  default     = 1000
}

variable "project_prefix" {
  description = "Name prefix to use for projects created."
  type        = string
  default     = "prj"
}

variable "folder_prefix" {
  description = "Name prefix to use for folders created."
  type        = string
  default     = "fldr"
}
