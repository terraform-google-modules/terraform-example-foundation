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

package templates.gcp.GCPIAMAllowedBindingsConstraintV3

template_name := "GCPIAMAllowedBindingsConstraintV3"

import data.validator.test_utils as test_utils

import data.test.fixtures.iam_allowed_bindings.assets as fixture_assets
import data.test.fixtures.iam_allowed_bindings.constraints as fixture_constraints

# Test denylist project
test_denylist_project_violation_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_project], template_name, 1)
}

# Test denylist public
test_denylist_public_violation_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_public], template_name, 2)
}

# Test denylist role
test_denylist_role_violation_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_role], template_name, 2)
}

# Test allowlist role domain
test_allowlist_role_domain_violation_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_allowlist_role_domain], template_name, 1)
}

test_allowlist_role_domain_violations {
	violations := test_utils.get_test_violations(fixture_assets, [fixture_constraints.iam_allowed_bindings_allowlist_role_domain], template_name)
	violation := violations[_]
	violation.details.role == "roles/owner"
	violation.details.member == "user:evil@notgoogle.com"
}

# Test allowlist role members (no violations)
test_allowlist_role_violation_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_allowlist_role_members], template_name, 0)
}

# Test denylist to BigQuery dataset for gmail.com addresses
test_restrict_gmail_bigquery_dataset_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_gmail_bigquery_dataset], template_name, 6)
}

test_restrict_gmail_bigquery_dataset_resources {
	resource_names := {
		"//bigquery.googleapis.com/projects/12345/datasets/testdataset1",
		"//bigquery.googleapis.com/projects/12345/datasets/testdataset3",
		"//bigquery.googleapis.com/projects/12345/datasets/testdataset4",
	}

	test_utils.check_test_violations_resources(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_gmail_bigquery_dataset], template_name, resource_names)
}

# Test denylist to BigQuery dataset for googlegroups.com addresses
test_restrict_googlegroups_bigquery_dataset_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_googlegroups_bigquery_dataset], template_name, 2)
}

test_restrict_googlegroups_bigquery_dataset_resources {
	resource_names := {"//bigquery.googleapis.com/projects/12345/datasets/testdataset2"}
	test_utils.check_test_violations_resources(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_googlegroups_bigquery_dataset], template_name, resource_names)
}

# Test denylist to specific BigQuery dataset for gmail.com addresses
test_restrict_gmail_specific_bigquery_dataset_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_denylist_asset_names], template_name, 4)
}

# Test allowlist to specific BigQuery dataset for gmail.com addresses
test_restrict_gmail_specific_bigquery_dataset_violations_count {
	test_utils.check_test_violations_count(fixture_assets, [fixture_constraints.iam_allowed_bindings_allowlist_asset_names], template_name, 0)
}
