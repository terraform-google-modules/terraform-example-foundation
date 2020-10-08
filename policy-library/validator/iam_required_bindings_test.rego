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

package templates.gcp.GCPIAMRequiredBindingsConstraintV1

import data.test.fixtures.iam_required_bindings.assets as fixture_assets
import data.test.fixtures.iam_required_bindings.constraints as fixture_constraints
import data.validator.test_utils as test_utils

template_name := "GCPIAMRequiredBindingsConstraintV1"

# Test that a required domain is absent in data
require_role_domain_violations := test_utils.get_test_violations(fixture_assets, [fixture_constraints.iam_required_bindings_role_domain], template_name)

test_require_role_domain_violations {
	count(require_role_domain_violations) = 3
	violation := require_role_domain_violations[_]
	violation.details.role == "roles/owner"
	violation.details.required_member == "user:*@required-group.com"
}

# Test that a required member is absent in data
require_role_member_violations := test_utils.get_test_violations(fixture_assets, [fixture_constraints.iam_required_bindings_role_members], template_name)

test_require_role_member_violations {
	count(require_role_member_violations) = 3
	violation := require_role_member_violations[_]
	violation.details.role == "roles/owner"
	violation.details.required_member == "user:required@notgoogle.com"
}

# Test that only Project resources are parsed
test_require_project_violations {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_required_bindings_project], template_name, 6)
}

# Test for no violations
test_require_role_no_violations {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_required_bindings_role_domain_all], template_name, 0)
}

# Test with empty members params
test_require_role_no_violations {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_required_bindings_none], template_name, 0)
}

# Test that only specific Project resource asset names are parsed
test_require_project_violations_asset_name {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_required_bindings_project_asset_name], template_name, 3)
}
