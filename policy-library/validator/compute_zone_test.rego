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

package templates.gcp.GCPComputeZoneConstraintV1

import data.test.fixtures.compute_zone.assets.disks as fixture_disks
import data.test.fixtures.compute_zone.assets.instances as fixture_instances
import data.test.fixtures.compute_zone.constraints as fixture_constraints

# Final all violations of our test cases

find_violations[violation] {
	asset := data.assets[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as asset with input.constraint as constraint
	total_issues := count(issues)
	violation := issues[_]
}

# Test logic for allowlisting/denylisting
test_target_zone_match_count_allowlist {
	target_zone_match_count("allowlist", match_count)
	match_count == 0
}

test_target_zone_match_count_denylist {
	target_zone_match_count("denylist", match_count)
	match_count == 1
}

# Test for no violations with no assets
test_compute_zone_no_assets {
	found_violations := find_violations with data.assets as []

	count(found_violations) == 0
}

# Test for no violations with no constraints
test_compute_zone_no_constraints {
	trace(sprintf("fixture_instances count: %v", [count(fixture_instances)]))
	trace(sprintf("fixture_disks count: %v", [count(fixture_disks)]))
	combined_assets := array.concat(fixture_instances, fixture_disks)
	trace(sprintf("combined_assets count: %v", [count(combined_assets)]))
	found_violations := find_violations with data.assets as combined_assets
		 with data.constraints as []

	count(found_violations) == 0
}

# Test for no violations with empty parameters
violations_with_empty_parameters[violation] {
	constraints := [fixture_constraints.zone_default]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_default {
	found_violations := violations_with_empty_parameters

	count(found_violations) == 0
}

# Test empty denylist
violations_with_empty_denylist[violation] {
	constraints := [fixture_constraints.denylist_none]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_denylist_none {
	found_violations := violations_with_empty_denylist

	count(found_violations) == 0
}

# Test empty allowlist
violations_with_empty_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_none]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_allowlist_none {
	found_violations := violations_with_empty_allowlist

	count(found_violations) == count(array.concat(fixture_instances, fixture_disks))
}

# Test denylist with single zone
violations_with_single_denylist[violation] {
	constraints := [fixture_constraints.denylist_one]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_denylist_one {
	found_violations := violations_with_single_denylist
	count(found_violations) == 1

	violation := found_violations[_]
	resource_name := "//compute.googleapis.com/projects/sandbox2/zones/asia-east1-b/disks/disk-asia-west1-b"
	is_string(violation.msg)
	is_object(violation.details)
}

# Test denylist with single zone and one exemption
violations_with_single_denylist_exemption[violation] {
	constraints := [fixture_constraints.denylist_one_exemption]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_denylist_one_exemption {
	found_violations := violations_with_single_denylist_exemption
	count(found_violations) == 0
}

# Test allowlist with single zone
violations_with_single_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_one]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_allowlist_one {
	found_violations := violations_with_single_allowlist

	count(found_violations) == count(array.concat(fixture_instances, fixture_disks)) - 1
}

# Test allowlist with single zone and one exemption
violations_with_single_allowlist_exemption[violation] {
	constraints := [fixture_constraints.allowlist_one_exemption]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_allowlist_one_exemption {
	found_violations := violations_with_single_allowlist_exemption

	count(found_violations) == count(array.concat(fixture_instances, fixture_disks)) - 2
}

# Test denylist with all zones
violations_with_full_denylist[violation] {
	constraints := [fixture_constraints.denylist_all]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_denylist_all {
	found_violations := violations_with_full_denylist

	count(found_violations) == count(array.concat(fixture_instances, fixture_disks))
}

# Test allowlist with all zones
violations_with_full_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_all]
	combined_assets := array.concat(fixture_instances, fixture_disks)
	found_violations := find_violations with data.assets as combined_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_compute_zone_allowlist_all {
	found_violations := violations_with_full_allowlist

	count(found_violations) == 0
}
