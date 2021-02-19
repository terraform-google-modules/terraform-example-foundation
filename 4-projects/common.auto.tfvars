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

billing_account = "01B29E-828C10-4D001A"

org_id = "684124036889"

terraform_service_account = "cmek-gcs-terraform@cmek-gcs-test.iam.gserviceaccount.com"

access_context_manager_policy_id = "740493296521"
                                    
//Optional - for development.  Will place all resources under a specific folder instead of org root
parent_folder = "895060319969"
