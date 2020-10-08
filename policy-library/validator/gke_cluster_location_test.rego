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

package templates.gcp.GKEClusterLocationConstraintV3

# Importing the test data
import data.test.fixtures.gke_cluster_location.assets as fixture_assets

# Importing the test constraints
import data.test.fixtures.gke_cluster_location.constraints.allowlist_all as allowlist_all
import data.test.fixtures.gke_cluster_location.constraints.allowlist_none as allowlist_none
import data.test.fixtures.gke_cluster_location.constraints.allowlist_one as allowlist_one
import data.test.fixtures.gke_cluster_location.constraints.allowlist_one_exemption as allowlist_one_exemption
import data.test.fixtures.gke_cluster_location.constraints.denylist_all as denylist_all
import data.test.fixtures.gke_cluster_location.constraints.denylist_none as denylist_none
import data.test.fixtures.gke_cluster_location.constraints.denylist_one as denylist_one
import data.test.fixtures.gke_cluster_location.constraints.denylist_one_exemption as denylist_one_exemption

# Find all violations on our test cases
find_all_violations[violation] {
	resources := data.resources[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as resources
		 with input.constraint as constraint

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

# Test for no violations with no assets
test_gke_cluster_location_no_assets {
	violations := find_all_violations with data.resources as []

	count(violations) == 0
}

# Test empty denylist
violations_with_empty_denylist[violation] {
	constraints := [denylist_none]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_denylist_none {
	violations := violations_with_empty_denylist

	count(violations) == 0
}

# Test empty allowlist
violations_with_empty_allowlist[violation] {
	constraints := [allowlist_none]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_allowlist_none {
	violations := violations_with_empty_allowlist

	count(violations) == count(fixture_assets)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust3",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test denylist with single location
violations_with_single_denylist[violation] {
	constraints := [denylist_one]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_denylist_one {
	violations := violations_with_single_denylist

	count(violations) == 1

	resource_name := {x | x = violations[_].details.resource}

	expected_resource_name := {"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust3"}

	resource_name == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test allowlist with single location
violations_with_single_allowlist[violation] {
	constraints := [allowlist_one]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_allowlist_one {
	violations := violations_with_single_allowlist

	count(violations) == 2

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test denylist with single location and one exemption
violations_with_single_denylist_exemption[violation] {
	constraints := [denylist_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_denylist_one_exemption {
	violations := violations_with_single_denylist_exemption

	count(violations) == 1

	resource_name := {x | x = violations[_].details.resource}

	expected_resource_name := {"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2"}

	resource_name == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test allowlist with single location and one exemption
violations_with_single_allowlist_exemption[violation] {
	constraints := [allowlist_one_exemption]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_allowlist_one_exemption {
	violations := violations_with_single_allowlist_exemption

	count(violations) == 1

	resource_name := {x | x = violations[_].details.resource}

	expected_resource_name := {"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2"}

	resource_name == expected_resource_name

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test denylist with all locations
violations_with_full_denylist[violation] {
	constraints := [denylist_all]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_denylist_all {
	violations := violations_with_full_denylist

	count(violations) == count(fixture_assets)

	resource_names := {x | x = violations[_].details.resource}

	expected_resource_names := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust3",
	}

	resource_names == expected_resource_names

	violation := violations[_]
	is_string(violation.msg)
	is_object(violation.details)
}

# Test allowlist with all locations
violations_with_full_allowlist[violation] {
	constraints := [allowlist_all]
	violations := find_all_violations with data.resources as fixture_assets
		 with data.test_constraints as constraints

	violation := violations[_]
}

test_gke_cluster_location_allowlist_all {
	violations := violations_with_full_allowlist

	count(violations) == 0
}
