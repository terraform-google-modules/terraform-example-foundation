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

package templates.gcp.GCPGKERestrictPodTrafficConstraintV1

import data.validator.gcp.lib as lib

all_violations[violation] {
	resource := data.test.fixtures.gke_restrict_pod_traffic.assets[_]
	constraint := data.test.fixtures.gke_restrict_pod_traffic.constraints.restrict_gke_pod_traffic

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

good_config_no_violations[violation] {
	resource := data.test.fixtures.assets.gke_restrict_pod_traffic[_]
	constraint := data.test.fixtures.constraints.restrict_gke_pod_traffic

	resource.name = "//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust4"

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

test_violations_basic {
	# 3 violation cases in the test fixtures:
	#   1. network_policy_config disabled
	#   2. network_policy does not exist
	#   3. network_policy exists and set to false
	#   4. podsecurityconfig does not exist
	#   5. podsecurityconfig exists and set to false
	count(all_violations) == 5
	violation := all_violations[_]
	resource_names := {x | x = all_violations[_].details.resource}
	expected_resource_name := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust3",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust5",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust6",
	}

	resource_names == expected_resource_name
}

test_all_enabled_no_violation {
	count(good_config_no_violations) == 0
}
