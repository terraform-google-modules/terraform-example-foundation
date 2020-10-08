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

package templates.gcp.GCPGKEEnableShieldedNodesConstraintV1

import data.test.fixtures.gke_enable_shielded_nodes.assets as fixture_assets
import data.test.fixtures.gke_enable_shielded_nodes.constraints as fixture_constraints
import data.validator.gcp.lib as lib

import data.validator.test_utils as test_utils

template_name := "GCPGKEEnableShieldedNodesConstraintV1"

test_disabled_shielded_nodes {
	expected_resource_names = {
		"//container.googleapis.com/projects/transfer-repo/zones/us-central1-c/clusters/shielded-nodes-disabled",
		"//container.googleapis.com/projects/transfer-repo/zones/us-central1-c/clusters/shielded-nodes-enabled-noboot",
	}

	test_utils.check_test_violations(fixture_assets, [fixture_constraints.enable_shielded_nodes], template_name, expected_resource_names)
}
