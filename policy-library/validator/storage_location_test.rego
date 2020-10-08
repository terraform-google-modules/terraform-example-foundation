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

package templates.gcp.GCPStorageLocationConstraintV1

import data.test.fixtures.storage_location.assets.storage_buckets as fixture_buckets
import data.test.fixtures.storage_location.constraints as fixture_constraints

# Final all violations of our test cases

find_violations[violation] {
	asset := data.assets[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as asset with input.constraint as constraint
	total_issues := count(issues)
	violation := issues[_]
}

# Test logic for allowlisting/denylisting
test_target_location_match_count_allowlist {
	target_location_match_count("allowlist", match_count)
	match_count == 0
}

test_target_location_match_count_denylist {
	target_location_match_count("denylist", match_count)
	match_count == 1
}

# Test for no violations with empty parameters
violations_with_empty_parameters[violation] {
	constraints := [fixture_constraints.location_default]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_default {
	found_violations := violations_with_empty_parameters

	count(found_violations) == 0
}

# Test empty denylist
violations_with_empty_denylist[violation] {
	constraints := [fixture_constraints.denylist_none]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_denylist_none {
	found_violations := violations_with_empty_denylist

	count(found_violations) == 0
}

# Test empty allowlist
violations_with_empty_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_none]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_allowlist_none {
	found_violations := violations_with_empty_allowlist
	count(found_violations) == count(fixture_buckets)
}

# Test denylist with single location
violations_with_single_denylist[violation] {
	constraints := [fixture_constraints.denylist_one]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_denylist_one {
	found_violations := violations_with_single_denylist
	count(found_violations) == 1

	violation := found_violations[_]
	violation.details.resource == "//storage.googleapis.com/my-storage-bucket"
	is_string(violation.msg)
	is_object(violation.details)
}

# Test denylist with single location and one exemption
violations_with_single_denylist_exemption[violation] {
	constraints := [fixture_constraints.denylist_one_exemption]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_denylist_one_exemption {
	found_violations := violations_with_single_denylist_exemption
	count(found_violations) == 0
}

# Test allowlist with single location
violations_with_single_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_one]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_allowlist_one {
	found_violations := violations_with_single_allowlist
	count(found_violations) == count(fixture_buckets) - 1
}

# Test allowlist with single location and one exemption
violations_with_single_allowlist_exemption[violation] {
	constraints := [fixture_constraints.allowlist_one_exemption]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_allowlist_one_exemption {
	found_violations := violations_with_single_allowlist_exemption

	count(found_violations) == count(fixture_buckets) - 2
}

# Test denylist with all locations
violations_with_full_denylist[violation] {
	constraints := [fixture_constraints.denylist_all]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_denylist_all {
	found_violations := violations_with_full_denylist

	count(found_violations) == count(fixture_buckets)
}

# Test allowlist with all locations
violations_with_full_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_all]
	found_violations := find_violations with data.assets as fixture_buckets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_storage_bucket_allowlist_all {
	found_violations := violations_with_full_allowlist

	count(found_violations) == 0
}
