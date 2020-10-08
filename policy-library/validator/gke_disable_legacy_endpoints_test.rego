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

package templates.gcp.GCPGKEDisableLegacyEndpointsConstraintV1

import data.validator.gcp.lib as lib

all_violations[violation] {
	resource := data.test.fixtures.gke_disable_legacy_endpoints.assets[_]
	constraint := data.test.fixtures.gke_disable_legacy_endpoints.constraints.disable_gke_legacy_endpoints

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

test_nodepool_legacy_endpoints_disabled {
	violation := all_violations[_]
	resource_names := {x | x = violation.details.resource}
	not resource_names["//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust"]
}

test_nodepool_with_no_nodeconfig {
	violation := all_violations[_]
	violation.details.resource == "//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2"
}

test_nodepool_with_one_enabled_one_disabled {
	violation := all_violations[_]
	violation.details.resource == "//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust3"
}
