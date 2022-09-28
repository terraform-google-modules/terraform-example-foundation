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
  Environment Folder
*****************************************/

resource "google_folder" "env" {
  display_name = "${local.folder_prefix}-${var.env}"
  parent       = local.parent
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [google_folder.env]

  destroy_duration = "30s"
}

resource "google_tags_tag_binding" "bind_folder_env" {
  parent    = "//cloudresourcemanager.googleapis.com/${google_folder.env.id}"
  tag_value = local.tags["environment_${var.env}"]
}
