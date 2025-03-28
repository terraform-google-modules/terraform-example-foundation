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

locals {
  env_business_unit_folder_name = "${var.folder_prefix}-${var.env}-${var.business_code}"
}

resource "google_folder" "env_business_unit" {
  display_name        = local.env_business_unit_folder_name
  parent              = local.env_folder_name
  deletion_protection = var.folder_deletion_protection
}
