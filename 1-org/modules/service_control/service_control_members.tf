/**
 * Copyright 2026 Google LLC
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


locals {

  member_policies_map = var.allow_additional_member_types ? {
    member_ingress = {
      from = {
        identities = var.members
        sources = {
          access_level = "*" # Allows access from any IP/network, matching standard Access Level behavior
        }
      }

      to = {
        resources = ["*"] # Applies to all projects within this perimeter
        operations = {
          service_name = { "*" = {} } # Allows all services
        }
      }
    }
  } : {}

  member_policies_dry_run_map = var.allow_additional_member_types ? {
    member_ingress_dry_run = {
      from = {
        identities = var.members_dry_run
        sources = {
          access_level = "*" # Allows access from any IP/network, matching standard Access Level behavior
        }
      }

      to = {
        resources = ["*"] # Applies to all projects within this perimeter
        operations = {
          service_name = { "*" = {} } # Allows all services
        }
      }
    }

  } : {}
}
