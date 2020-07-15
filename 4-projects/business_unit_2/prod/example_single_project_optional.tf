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

# locals {
#   env           = "prod"
#   env_code      = element(split("", local.env), 0)
#   business_code = "bu2"
# }

# module "example_single_project_optional" {
#   source = "../../modules/single_project"

#   org_id                      = var.org_id
#   billing_account             = var.billing_account
#   impersonate_service_account = var.terraform_service_account
#   folder_id                   = var.parent_folder
#   environment                 = local.env
#   skip_gcloud_download        = var.skip_gcloud_download

#   # Metadata
#   project_prefix    = "prj-${local.business_code}-${local.env_code}-sample-single"
#   cost_centre       = "cost-centre-1"
#   application_name  = "sample-single-prj-app-${local.business_code}-${local.env_code}"
#   billing_code      = "1234"
#   primary_contact   = "example@example.com"
#   secondary_contact = "example2@example.com"
#   business_code     = local.business_code

#   # Network Setting (Optional)
#   enable_networking    = true
#   subnet_ip_cidr_range = "10.3.0.0/16"
#   subnet_secondary_ranges = [{
#     range_name    = "gke-pod",
#     ip_cidr_range = "10.4.0.0/16"
#     }, {
#     range_name    = "gke-svc",
#     ip_cidr_range = "10.5.0.0/16"
#   }]

#   # DNS Setting (Optional)
#   enable_private_dns = true
#   domain             = var.domain
# }
