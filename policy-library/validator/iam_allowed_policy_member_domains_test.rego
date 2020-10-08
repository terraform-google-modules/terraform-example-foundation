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

package templates.gcp.GCPIAMAllowedPolicyMemberDomainsConstraintV2

import data.test.fixtures.iam_allowed_policy_member_domains.assets as fixture_assets
import data.test.fixtures.iam_allowed_policy_member_domains.constraints as fixture_constraints

# Find all violations on our test cases
find_violations[violation] {
	instance := data.instances[_]
	constraint := data.test_constraints[_]

	issues := deny with input.asset as instance
		 with input.constraint as constraint

	total_issues := count(issues)

	violation := issues[_]
}

# Confim no violations with no resources
test_no_resources {
	found_violations := find_violations with data.instances as []

	count(found_violations) = 0
}

violations_one_project[violation] {
	constraints := [fixture_constraints.iam_allowed_policy_member_two_domains]

	found_violations := find_violations with data.instances as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_one_project_with_unexpected_domain {
	found_violations := violations_one_project

	# The "12345" project should have 2 members from unexpected domains.
	count(found_violations) = 2
	projects := [v | v = found_violations[_]; contains(v.msg, "//cloudresourcemanager.googleapis.com/projects/12345")]
	count(projects) == 2
	members := {m | m = found_violations[_].details.member}
	members == {"user:bad@notgoogle.com", "serviceAccount:service-12345@notiam.gserviceaccount.com"}
}

violations_none[violation] {
	constraints := [fixture_constraints.iam_allowed_policy_member_all_domains]

	found_violations := find_violations with data.instances as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_all_projects_with_expected_domains {
	found_violations := violations_none

	count(found_violations) = 0
}

violations_project_reference[violation] {
	constraints := [fixture_constraints.iam_allowed_policy_member_reject_project_reference]

	found_violations := find_violations with data.instances as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_reject_project_reference {
	found_violations := violations_project_reference
	count(found_violations) = 1
	found_violations[_].details.member == "projectViewer:my-project"
}

violations_reject_sub_domains[violation] {
	constraints := [fixture_constraints.iam_allowed_policy_member_reject_sub_domains]

	found_violations := find_violations with data.instances as fixture_assets
		 with data.test_constraints as constraints

	violation := found_violations[_]
}

test_reject_sub_domains {
	found_violations := violations_reject_sub_domains
	count(found_violations) = 3
	projects_1 := [v | v = found_violations[_]; contains(v.msg, "//cloudresourcemanager.googleapis.com/projects/12345")]
	count(projects_1) == 2
	projects_2 := [v | v = found_violations[_]; contains(v.msg, "//cloudresourcemanager.googleapis.com/projects/186783260185")]
	count(projects_2) == 1
	members := {m | m = found_violations[_].details.member}
	members == {"user:bad@sub.google.com", "serviceAccount:service-186783260185@dataflow-service-producer-prod.iam.gserviceaccount.com", "serviceAccount:service-12345@dataflow-service-producer-prod.iam.gserviceaccount.com"}
}
