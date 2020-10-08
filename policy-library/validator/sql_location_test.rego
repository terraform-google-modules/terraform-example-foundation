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

package templates.gcp.GCPSQLLocationConstraintV1

import data.test.fixtures.sql_location.assets.sql_instances as fixture_sql_instances
import data.test.fixtures.sql_location.constraints as fixture_constraints

find_violations[violation] {
	asset := data.assets[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as asset with input.constraint as constraint
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
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_default {
	found_violations := violations_with_empty_parameters
	count(found_violations) == 0
}

# Test empty denylist
violations_with_empty_denylist[violation] {
	constraints := [fixture_constraints.denylist_none]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_denylist_none {
	found_violations := violations_with_empty_denylist
	count(found_violations) == 0
}

# Test empty allowlist
violations_with_empty_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_none]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_allowlist_none {
	found_violations := violations_with_empty_allowlist
	count(found_violations) == count(fixture_sql_instances)

	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-1/instances/test-instance-1-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/test-instance-2-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-sydney"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/postgres-11-sydney"
}

# Test denylist with single location
violations_with_single_denylist[violation] {
	constraints := [fixture_constraints.denylist_one]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_denylist_one {
	found_violations := violations_with_single_denylist
	count(found_violations) == 3

	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-1/instances/test-instance-1-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/test-instance-2-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-singapore"
}

# Test denylist with single location and one exemption
violations_with_single_denylist_exemption[violation] {
	constraints := [fixture_constraints.denylist_one_exemption]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_denylist_one_exemption {
	found_violations := violations_with_single_denylist_exemption
	count(found_violations) == 2

	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-1/instances/test-instance-1-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-singapore"
}

# Test allowlist with single location
violations_with_single_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_one]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_allowlist_one {
	found_violations := violations_with_single_allowlist
	count(found_violations) == 2

	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-sydney"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/postgres-11-sydney"
}

# Test allowlist with single location and one exemption
violations_with_single_allowlist_exemption[violation] {
	constraints := [fixture_constraints.allowlist_one_exemption]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_allowlist_one_exemption {
	found_violations := violations_with_single_allowlist_exemption
	count(found_violations) == 1

	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/postgres-11-sydney"
}

# Test denylist with all locations
violations_with_full_denylist[violation] {
	constraints := [fixture_constraints.denylist_all]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_denylist_all {
	found_violations := violations_with_full_denylist
	count(found_violations) == count(fixture_sql_instances)

	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-1/instances/test-instance-1-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/test-instance-2-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-singapore"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/mysql-2nd-gen-sydney"
	found_violations[_].details.resource == "//cloudsql.googleapis.com/projects/test-project-2/instances/postgres-11-sydney"
}

# Test allowlist with all locations
violations_with_full_allowlist[violation] {
	constraints := [fixture_constraints.allowlist_all]
	found_violations := find_violations with data.assets as fixture_sql_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_sql_instance_allowlist_all {
	found_violations := violations_with_full_allowlist
	count(found_violations) == 0
}
