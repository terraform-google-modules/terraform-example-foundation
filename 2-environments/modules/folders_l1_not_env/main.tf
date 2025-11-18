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

data "google_tags_tag_key" "environment" {
  parent = var.parent
  short_name = "environment"
}


resource "google_folder" "l1" {
    display_name        = "${var.folder_prefix}-${var.folder_name}"
    parent              = var.parent
    deletion_protection = var.folder_deletion_protection
}

resource "time_sleep" "wait_60_seconds" {
  depends_on = [google_folder.l2]

  destroy_duration = "60s"
}

resource "google_folder" "l2" {
  count = "${length(var.level_2_folders)}"
    display_name        = "${var.folder_prefix}-${var.folder_abbreviated_name}-${lookup(var.level_2_folders[count.index],"folder_name")}"
    parent              = google_folder.l1.id
    deletion_protection = var.folder_deletion_protection
//    tags = {"${data.google_tags_tag_key.environment.id}":"${lookup(var.tags,lookup(var.level_2_folders[count.index],"env_tag_value"))}"}

    depends_on = [google_folder.l1]
}

resource "google_tags_tag_binding" "l2_tag_binding" {
  count = "${length(var.level_2_folders)}"
    parent    = "//cloudresourcemanager.googleapis.com/${google_folder.l2[count.index].id}"
    tag_value = lookup(var.tags,lookup(var.level_2_folders[count.index],"env_tag_value"))

  depends_on = [time_sleep.wait_60_seconds]
}
