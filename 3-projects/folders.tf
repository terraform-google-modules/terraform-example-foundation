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

data "google_active_folder" "products" {
  display_name = "products"
  parent       = "organizations/${var.org_id}"
}

/******************************************
  Second Level Folders
 *****************************************/
resource "google_folder" "app-sample-single" {
  parent       = data.google_active_folder.products.name
  display_name = "sample-app-single"
}

resource "google_folder" "app-sample-standard" {
  parent       = data.google_active_folder.products.name
  display_name = "sample-app-standard"
}
