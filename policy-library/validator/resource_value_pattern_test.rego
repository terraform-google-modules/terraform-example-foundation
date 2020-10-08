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

package templates.gcp.GCPResourceValuePatternConstraintV1

import data.test.fixtures.resource_value_pattern.assets as fixture_assets
import data.test.fixtures.resource_value_pattern.constraints.list as fixture_constraints

import data.validator.test_utils as test_utils

template_name := "GCPResourceValuePatternConstraintV1"

# Helper to lookup a constraint based on its name via metadata, not package
lookup_constraint[name] = [c] {
	c := fixture_constraints[_]
	c.metadata.name = name
}

# Helper to execute constraints against assets
find_violations[violation] {
	asset := data.assets[_]
	constraint := data.test_constraints[_]
	issues := deny with input.asset as asset with input.constraint as constraint
	total_issues := count(issues)
	violation := issues[_]
}

# Helper to create a set of resource names from violations
resource_names[name] {
	# Not sure why I need this, data.violations was a array_set but unless
	# casted as an array all evals of X[_] would fail.  Tested iterating sets in
	# playground and they work fine, so I am not sure the problem here.
	a := cast_array(data.violations)
	i := a[_]

	name := i.details.resource
}

test_resource_value_pattern_optional_on_multiple_resources {
	expected_resources := {
		"//compute.googleapis.com/projects/test-project/zones/us-east1-c/instances/vm-no-ip",
		"//cloudresourcemanager.googleapis.com/projects/15100256534",
	}

	test_utils.check_test_violations(fixture_assets, lookup_constraint.optional_billing_id_on_multiple_assets, template_name, expected_resources)
}

test_resource_value_pattern_required_field_with_pattern {
	expected_resources := {
		"//cloudresourcemanager.googleapis.com/projects/1510025653",
		"//cloudresourcemanager.googleapis.com/projects/15100256534",
	}

	test_utils.check_test_violations(fixture_assets, lookup_constraint.required_billing_id_on_project, template_name, expected_resources)
}

test_resource_value_pattern_no_pattern_violations {
	expected_resources := {"//cloudresourcemanager.googleapis.com/projects/1510025653"}

	test_utils.check_test_violations(fixture_assets, lookup_constraint.required_billing_id_no_pattern, template_name, expected_resources)
}

test_denylist_resource_value_pattern_optional_on_multiple_resources {
	expected_resources := {"//cloudresourcemanager.googleapis.com/projects/1510025652"}

	test_utils.check_test_violations(fixture_assets, lookup_constraint.optional_billing_id_on_multiple_assets_denylist, template_name, expected_resources)
}

test_denylist_resource_value_pattern_required_field_with_pattern {
	expected_resources := {
		"//cloudresourcemanager.googleapis.com/projects/1510025652",
		"//cloudresourcemanager.googleapis.com/projects/1510025653",
	}

	test_utils.check_test_violations(fixture_assets, lookup_constraint.required_billing_id_on_project_denylist, template_name, expected_resources)
}

test_denylist_resource_value_pattern_no_pattern_violations {
	expected_resources := {"//cloudresourcemanager.googleapis.com/projects/1510025653"}
	test_utils.check_test_violations(fixture_assets, lookup_constraint.required_billing_id_no_pattern_denylist, template_name, expected_resources)
}

# Boolean truth table is 16 rows, 2^4 (2 states, 4 variables)
# Test all permutations to ensure we have full coverage, no multiple outputs
# and no unknowns
# [is_required, has_pattern, has_field, pattern, label_value]
allowlist_count_of_test_scenarios = count(allowlist_validation_scenario_table)

denylist_count_of_test_scenarios = count(denylist_validation_scenario_table)

allowlist_validation_scenario_table = [
	{"is_required": true, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": true, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": true},
	{"is_required": true, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": true},
	{"is_required": true, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": true},
	{"is_required": true, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": true, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": true, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": true},
	{"is_required": true, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": true},
	{"is_required": false, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": true},
	{"is_required": false, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
]

denylist_validation_scenario_table = [
	{"is_required": true, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": true},
	{"is_required": true, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": true, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": true},
	{"is_required": true, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": true},
	{"is_required": true, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": true, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": true, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": true},
	{"is_required": true, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": true},
	{"is_required": false, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": true},
	{"is_required": false, "has_pattern": true, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": false, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": true, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": true, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "1234", "generate_violation": false},
	{"is_required": false, "has_pattern": false, "has_field": false, "pattern": "^\\d+$", "value": "abcd", "generate_violation": false},
]

is_valid_bool(mode, obj) = output {
	is_not_valid(mode, obj)
	output := true
}

is_valid_bool(mode, obj) = output {
	not is_not_valid(mode, obj)
	output := false
}

allowlist_all_is_valid_test_scenarios[[i, scenario]] {
	t := allowlist_validation_scenario_table[i]
	d := {"is_required": t.is_required, "has_pattern": t.has_pattern, "has_field": t.has_field, "pattern": t.pattern, "value": t.value}
	mode := "allowlist"
	result := is_valid_bool(mode, d)

	scenario = {
		"scenario": t,
		"result": result,
	}
}

test_allowlist_is_valid_test_scenarios {
	# ensure we are always returning a true / false from is_valid and not any unknowns
	count(allowlist_all_is_valid_test_scenarios) == allowlist_count_of_test_scenarios
}

denylist_all_is_valid_test_scenarios[[i, scenario]] {
	t := denylist_validation_scenario_table[i]
	d := {"is_required": t.is_required, "has_pattern": t.has_pattern, "has_field": t.has_field, "pattern": t.pattern, "value": t.value}
	mode := "denylist"
	result := is_valid_bool(mode, d)

	scenario = {
		"scenario": t,
		"result": result,
	}
}

test_denylist_is_valid_test_scenarios {
	# ensure we are always returning a true / false from is_valid and not any unknowns
	count(denylist_all_is_valid_test_scenarios) == denylist_count_of_test_scenarios
}

test_has_field_by_path {
	doc := {
		"labels": {
			"f": false,
			"id": "1234",
			"t": true,
			"tf_foo": "foo/project/google/v123",
		},
		"name": "myname",
	}

	has_field_by_path(doc, "name")
	has_field_by_path(doc, "labels.id")
	has_field_by_path(doc, "labels.f")
	has_field_by_path(doc, "labels.t")

	not has_field_by_path(doc, "unknown")
	not has_field_by_path(doc, "labels.unknown")
	not has_field_by_path(doc, "labels.f.unknown")
	not has_field_by_path(doc, "labels.t.unknown")
	not has_field_by_path(doc, "labels.tf_foo.unknown")
}

# Verifying default behavior
test_get_default_by_path {
	doc := {
		"labels": {
			"f": false,
			"id": "1234",
			"t": true,
			"tf_foo": "foo/project/google/v123",
		},
		"name": "myname",
	}

	get_default_by_path(doc, "name", "foo") == "myname"
	get_default_by_path(doc, "labels.id", "foo") == "1234"
	get_default_by_path(doc, "labels.t", false) == true
	get_default_by_path(doc, "labels.f", true) == false

	get_default_by_path(doc, "name1", "foo") == "foo"
	get_default_by_path(doc, "labels.id1", "foo") == "foo"
	get_default_by_path(doc, "labels.t1", false) == false
	get_default_by_path(doc, "labels.f1", true) == true
	get_default_by_path(doc, "labels.tf_foo.unknown", true) == true
	get_default_by_path(doc, "labels.tf_foo.unknown", false) == false
}
