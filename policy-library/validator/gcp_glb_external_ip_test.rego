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

package templates.gcp.GCPGLBExternalIpAccessConstraintV1

import data.test.fixtures.gcp_glb_external_ip.assets as fixture_instances
import data.test.fixtures.gcp_glb_external_ip.constraints as fixture_constraints

# Find all violations on our test cases
find_violations[violation] {
	instance := data.instances[_]
	constraint := data.test_constraints[_]

	issues := deny with input.asset as instance
		 with input.constraint as constraint

	total_issues := count(issues)

	violation := issues[_]
}

# Test logic for allowlisting/denylisting
test_target_instance_match_count_allowlist {
	target_instance_match_count("allowlist", match_count)
	match_count = 0
}

test_target_instance_match_count_denylist {
	target_instance_match_count("denylist", match_count)
	match_count = 1
}

# Confim no violations with no instances
test_external_ip_no_instances {
	found_violations := find_violations with data.instances as []

	count(found_violations) = 0
}

# Confirm no violations with no constraints
test_external_ip_no_constraints {
	found_violations := find_violations with data.instances as fixture_instances
		 with data.constraints as []

	count(found_violations) = 0
}

violations_with_empty_parameters[violation] {
	constraints := [fixture_constraints.glb_forbid_external_ip_default]

	found_violations := find_violations with data.instances as fixture_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

# Confirm that no violation is found with empty parameters.
test_external_ip_default {
	found_violations := violations_with_empty_parameters

	count(found_violations) = 0
}

allowlist_violations[violation] {
	constraints := [fixture_constraints.glb_forbid_external_ip_allowlist]

	found_violations := find_violations with data.instances as fixture_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

denylist_violations[violation] {
	constraints := [fixture_constraints.glb_forbid_external_ip_denylist]

	found_violations := find_violations with data.instances as fixture_instances
		 with data.test_constraints as constraints

	violation := found_violations[_]
}
