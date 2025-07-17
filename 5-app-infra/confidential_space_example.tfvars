/**
 * Copyright 2025 Google LLC
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

# To be added in README.md
# export IMAGE_DIGEST=$(gcloud artifacts docker images list us-central1-docker.pkg.dev/prj-b-cicd-etuf/tf-runners/confidential_space_image --include-tags --filter='tags:"latest"' --format="value(DIGEST)"  2>/dev/null)
# echo $IMAGE_DIGEST
# sed -i'' -e "s/IMAGE_DIGEST/${IMAGE_DIGEST}/" ./confidential_space.tfvars

image_digest                         = "IMAGE_DIGEST"
confidential_space_workload_operator = "CONFIDENTIAL_SPACE_WORKLOAD_OPERATOR"

