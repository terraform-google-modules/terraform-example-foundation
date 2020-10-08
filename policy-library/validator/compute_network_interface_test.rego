#
# Copyright 2019 Google LLC
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

package templates.gcp.GCPComputeAllowedNetworksConstraintV2

template_name := "GCPComputeAllowedNetworksConstraintV2"

import data.validator.gcp.lib as lib
import data.validator.test_utils as test_utils

import data.test.fixtures.compute_network_interface.assets as fixture_assets
import data.test.fixtures.compute_network_interface.constraints.allowlist as fixture_constraint

test_allowed_interfaces {
	expected_resource_names := {"//compute.googleapis.com/projects/vpc-sc-pub-sub-billing-alerts/zones/us-central1-b/instances/invalid-instance"}

	test_utils.check_test_violations(fixture_assets, [fixture_constraint], template_name, expected_resource_names)
}
