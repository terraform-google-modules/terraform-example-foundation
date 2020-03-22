
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

variable application_name {
    description = "The name of the application on GCP"
    type = string
}

variable project_index {
    description = "The index used for application network allocation"
    type = number
}

variable cidr_vms {
    description = "The network range allocated to apps, e.g. GKE worker nodes or GCE"
    type = string
}

variable cidr_gke_pods {
    description = "The network range allocated to GKE pods"
    type = string
}

variable cidr_gke_services {
    description = "The network range allocated to GKE services"
    type = string
}

variable cidr_gke_masters {
    description = "The network range allocated to private GKE master nodes"
    type = string
}

variable subnet_size {
    description = "The network bit to allocate for each application"
    type = number
}
