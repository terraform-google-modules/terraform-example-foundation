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

terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      // version 4.31.0 removed because of issue https://github.com/hashicorp/terraform-provider-google/issues/12226
      // version 6.26.0 and 6.27.0 removed because of the bug https://github.com/hashicorp/terraform-provider-google/issues/21950
      source  = "hashicorp/google"
      version = ">= 3.50, != 4.31.0, != 6.26.0, != 6.27.0, < 7.0"
    }

    google-beta = {
      // version 4.31.0 removed because of issue https://github.com/hashicorp/terraform-provider-google/issues/12226
      // version 6.26.0 and 6.27.0 removed because of the bug https://github.com/hashicorp/terraform-provider-google/issues/21950
      source  = "hashicorp/google-beta"
      version = ">= 3.50, != 4.31.0, != 6.26.0, != 6.27.0, < 7.0"
    }

    // Un-comment gitlab required_providers when using gitlab CI/CD
    # gitlab = {
    #   source  = "gitlabhq/gitlab"
    #   version = "16.6.0"
    # }

    // Un-comment github required_providers when using GitHub Actions
    # github = {
    #   source  = "integrations/github"
    #   version = "5.34.0"
    # }

    // Un-comment tfe required_providers when using Terraform Cloud
    # tfe = {
    #   source  = "hashicorp/tfe"
    #   version = "0.48.0"
    # }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-example-foundation:bootstrap/v4.1.0"
  }

}
