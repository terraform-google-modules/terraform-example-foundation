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

package templates.gcp.GCPEnforceNamingConstraintV1

import data.validator.gcp.lib as lib

import data.test.fixtures.gcp_enforce_naming.assets as fixture_assets
import data.test.fixtures.gcp_enforce_naming.constraints as fixture_constraints

# Find all violations on our test cases
find_violations[violation] {
	asset := data.assets[_]
	constraint := data.test_constraints

	issues := deny with input.asset as asset
		 with input.constraint as constraint

	total_issues := count(issues)

	violation := issues[_]
}

test_name_convention_all_match {
	violations := find_violations with data.assets as fixture_assets
		 with data.test_constraints as fixture_constraints.all_match

	count(violations) == 0
}

test_name_convention_no_match {
	violations := find_violations with data.assets as fixture_assets
		 with data.test_constraints as fixture_constraints.partial_match

	count(violations) > 0
}

test_get_only_asset_name {
	"my_self_signed" == get_only_asset_name("//compute.googleapis.com/projects/test-project/global/sslCertificates/my_self_signed")
	"" == get_only_asset_name("")
}

test_check_asset_and_return_its_rules {
	lib.get_constraint_params(fixture_constraints.all_match, params)
	naming_rules := lib.get_default(params, "naming_rules", [])
	trace(sprintf("the naming rules %v", [naming_rules]))
	patterns := check_asset_and_return_its_rules("compute.googleapis.com/SslCertificate", naming_rules)
	is_array(patterns)
	count(patterns) == 2
}

test_check_asset_and_return_its_rules_no_match {
	lib.get_constraint_params(fixture_constraints.all_match, params)
	naming_rules := lib.get_default(params, "naming_rules", [])
	not check_asset_and_return_its_rules("compute.googleapis.com/ForwardingRules", naming_rules)
	not check_asset_and_return_its_rules("compute.googleapis.com/ForwardingRules", [])
}

test_no_name_match {
	not no_name_match("my-match-name", [".*"])
	not no_name_match("my-match-name", ["my-match-.*", "nomatch"])
	no_name_match("my-match-name", ["nomatch1", "nomatch2"])
}
