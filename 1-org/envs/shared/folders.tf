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

/******************************************
  Top level folders
 *****************************************/

resource "google_folder" "common" {
  display_name = "${local.folder_prefix}-common"
  parent       = local.parent
  # deletion_protection = var.folder_deletion_protection // uncommnet after updating "GoogleCloudPlatform/cloud-functions/google" to provider v6
}

resource "google_folder" "network" {
  display_name = "${local.folder_prefix}-network"
  parent       = local.parent
  # deletion_protection = var.folder_deletion_protection // uncommnet after updating "GoogleCloudPlatform/cloud-functions/google" to provider v6
}
