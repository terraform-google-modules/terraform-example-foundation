#
# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package templates.gcp.GCPGKEContainerOptimizedOSConstraintV1

import data.validator.gcp.lib as lib

cos_violations[violation] {
	resource := data.test.fixtures.gke_container_optimized_os.assets[_]
	constraint := data.test.fixtures.gke_container_optimized_os.constraints.gke_container_optimized_os

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

cos_or_containerd_violations[violation] {
	resource := data.test.fixtures.gke_container_optimized_os.assets[_]
	constraint := data.test.fixtures.gke_container_optimized_os.constraints.gke_container_optimized_os_containerd

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

# Tests that we can identify all clusters that are NOT using COS.
test_nodepool_cos {
	resource_names := {x | x = cos_violations[_].details.resource}

	expected_resource_name := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/containerd",
	}

	trace(sprintf("Error: %s", [resource_names]))
	resource_names == expected_resource_name
}

# Tests that we can identify all clusters that are NOT using COS or COS_CONTAINERD
test_nodepool_cos_or_containerd {
	resource_names := {x | x = cos_or_containerd_violations[_].details.resource}

	expected_resource_name := {"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2"}

	trace(sprintf("Error: %s", [resource_names]))
	resource_names == expected_resource_name
}
