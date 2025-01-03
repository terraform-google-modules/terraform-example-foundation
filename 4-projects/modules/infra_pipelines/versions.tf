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
      source  = "hashicorp/google"
      version = ">= 3.50, != 4.31.0"
    }
    google-beta = {
      // version 4.31.0 removed because of issue https://github.com/hashicorp/terraform-provider-google/issues/12226
      source  = "hashicorp/google-beta"
      version = ">= 3.50, != 4.31.0"
    }
    null = {
      source = "hashicorp/null"
    }
    random = {
      source = "hashicorp/random"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-example-foundation:infra_pipelines/v5.0.0"
  }

  provider_meta "google-beta" {
    module_name = "blueprints/terraform/terraform-example-foundation:infra_pipelines/v5.0.0"
  }
}
