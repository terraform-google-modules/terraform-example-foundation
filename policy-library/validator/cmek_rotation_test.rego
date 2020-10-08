#
# Copyright 2020 Google LLC
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

package templates.gcp.GCPCMEKRotationConstraintV1

template_name := "GCPCMEKRotationConstraintV1"

import data.validator.test_utils as test_utils

import data.test.fixtures.cmek_rotation.assets as fixture_assets

# Test exemptions
test_cmek_rotation_violations_exemptions_count {
	test_utils.check_test_violations_count(fixture_assets, [data.test.fixtures.cmek_rotation.constraints.exemptions], template_name, 1)
}

# Test no params (default to 1 year required rotation period)
test_cmek_rotation_violations_no_params_count {
	test_utils.check_test_violations_count(fixture_assets, [data.test.fixtures.cmek_rotation.constraints.no_params], template_name, 2)
}

# Test one hundred days
test_cmek_rotation_violations_one_hundred_days_resources {
	expected_resource_names := {
		"//cloudkms.googleapis.com/projects/test-project/locations/us-central1/keyRings/test-key-ring/cryptoKeys/rotation-never",
		"//cloudkms.googleapis.com/projects/test-project/locations/us-central1/keyRings/test-key-ring/cryptoKeys/rotation-100-days",
		"//cloudkms.googleapis.com/projects/test-project/locations/us-central1/keyRings/test-key-ring/cryptoKeys/rotation-365-days",
		"//cloudkms.googleapis.com/projects/test-project/locations/us-central1/keyRings/test-key-ring/cryptoKeys/rotation-400-days",
	}

	test_utils.check_test_violations_resources(fixture_assets, [data.test.fixtures.cmek_rotation.constraints.one_hundred_days], template_name, expected_resource_names)
}

# Test one year
test_cmek_rotation_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [data.test.fixtures.cmek_rotation.constraints.one_year], template_name, 2)
}

test_cmek_violations_basic {
	expected_resource_names := {
		"//cloudkms.googleapis.com/projects/test-project/locations/us-central1/keyRings/test-key-ring/cryptoKeys/rotation-never",
		"//cloudkms.googleapis.com/projects/test-project/locations/us-central1/keyRings/test-key-ring/cryptoKeys/rotation-400-days",
	}

	test_utils.check_test_violations_resources(fixture_assets, [data.test.fixtures.cmek_rotation.constraints.one_year], template_name, expected_resource_names)
}
