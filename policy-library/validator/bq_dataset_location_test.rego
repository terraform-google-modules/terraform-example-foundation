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

package templates.gcp.GCPBigQueryDatasetLocationConstraintV1

template_name := "GCPBigQueryDatasetLocationConstraintV1"

import data.validator.test_utils as test_utils

import data.test.fixtures.bq_dataset_location.assets.datasets as fixture_datasets
import data.test.fixtures.bq_dataset_location.assets.instances as fixture_instances
import data.test.fixtures.bq_dataset_location.constraints as fixture_constraints

# Test logic for allowlisting/denylisting
test_target_location_match_count_allowlist {
	target_location_match_count("allowlist", match_count)
	match_count == 0
}

test_target_location_match_count_denylist {
	target_location_match_count("denylist", match_count)
	match_count == 1
}

# Test for no violations with no assets
test_bq_dataset_location_no_assets {
	test_utils.check_test_violations_count([], fixture_constraints, template_name, 0)
}

# Test for no violations with no constraints
test_bq_dataset_location_no_constraints {
	test_utils.check_test_violations_count(fixture_datasets, [], template_name, 0)
}

# Test for no violations with empty parameters
test_bq_dataset_location_default {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.location_default], template_name, 0)
}

# Test empty denylist
test_compute_zone_denylist_none {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.denylist_none], template_name, 0)
}

# Test empty denylist with incorrect asset type
test_bq_dataset_location_denylist_none_incorrect_assets {
	combined_assets := array.concat(fixture_instances, fixture_datasets)
	test_utils.check_test_violations_count(combined_assets, [fixture_constraints.denylist_none], template_name, 0)
}

# Test empty allowlist
test_bq_dataset_location_allowlist_none {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.allowlist_none], template_name, count(fixture_datasets))
}

# Test empty allowlist with incorrect assets
test_bq_dataset_location_allowlist_none_incorrect_assets {
	combined_assets := array.concat(fixture_instances, fixture_datasets)
	test_utils.check_test_violations_count(combined_assets, [fixture_constraints.allowlist_none], template_name, count(fixture_datasets))
}

# Test denylist with single location
test_bq_dataset_location_denylist_one {
	expected_resource_names := {"//bigquery.googleapis.com/projects/sandbox2/datasets/us_west2_test_dataset"}

	test_utils.check_test_violations(fixture_datasets, [fixture_constraints.denylist_one], template_name, expected_resource_names)
}

# Test denylist with single location and one exemption
test_bq_dataset_location_denylist_one_exemption {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.denylist_one_exemption], template_name, 0)
}

# Test allowlist with single location
test_bq_dataset_location_allowlist_one {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.allowlist_one], template_name, count(fixture_datasets) - 1)
}

# Test allowlist with single location and one exemption
test_bq_dataset_location_allowlist_one_exemption {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.allowlist_one_exemption], template_name, count(fixture_datasets) - 2)
}

# Test denylist with all locations
test_bq_dataset_location_denylist_all {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.denylist_all], template_name, count(fixture_datasets))
}

# Test allowlist with all zones
test_bq_dataset_location_allowlist_all {
	test_utils.check_test_violations_count(fixture_datasets, [fixture_constraints.allowlist_all], template_name, 0)
}
