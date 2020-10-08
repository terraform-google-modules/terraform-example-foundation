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

package templates.gcp.GCPStorageBucketWorldReadableConstraintV1

template_name := "GCPStorageBucketWorldReadableConstraintV1"

# Importing the test data
import data.test.fixtures.storage_bucket_world_readable.assets as fixture_assets

# Importing the test constraints
import data.test.fixtures.storage_bucket_world_readable.constraints.forbid_world_readable_storage_bucket as forbid_world_readable_storage_bucket
import data.test.fixtures.storage_bucket_world_readable.constraints.forbid_world_readable_storage_bucket_empty_exemption as forbid_world_readable_storage_bucket_empty_exemption
import data.test.fixtures.storage_bucket_world_readable.constraints.forbid_world_readable_storage_bucket_multiple_exemption as forbid_world_readable_storage_bucket_multiple_exemption
import data.test.fixtures.storage_bucket_world_readable.constraints.forbid_world_readable_storage_bucket_one_exemption as forbid_world_readable_storage_bucket_one_exemption

# Import test utils
import data.validator.test_utils as test_utils

test_bucket_all_violations {
	expected_resource_names := {
		"//storage.googleapis.com/my-test-bucket",
		"//storage.googleapis.com/my-second-test-bucket",
	}

	test_utils.check_test_violations(fixture_assets, [forbid_world_readable_storage_bucket], template_name, expected_resource_names)
}

test_bucket_one_exemption {
	expected_resource_names := {"//storage.googleapis.com/my-test-bucket"}

	test_utils.check_test_violations(fixture_assets, [forbid_world_readable_storage_bucket_one_exemption], template_name, expected_resource_names)
}

test_bucket_multiple_exemption {
	test_utils.check_test_violations_count(fixture_assets, [forbid_world_readable_storage_bucket_multiple_exemption], template_name, 0)
}

test_bucket_empty_exemption {
	expected_resource_names := {
		"//storage.googleapis.com/my-test-bucket",
		"//storage.googleapis.com/my-second-test-bucket",
	}

	test_utils.check_test_violations(fixture_assets, [forbid_world_readable_storage_bucket_empty_exemption], template_name, expected_resource_names)
}
