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

package templates.gcp.GCPStorageBucketRetentionConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)

	asset := input.asset
	asset.asset_type == "storage.googleapis.com/Bucket"

	# Check if resource is in exempt list
	exempt_list := params.exemptions
	matches := {asset.name} & cast_set(exempt_list)
	count(matches) == 0

	violations := get_diff
	count(violations) > 0
	violation_msg := concat(" & ", violations)
	message := sprintf("Storage bucket %v has a retention policy violation: %v", [asset.name, violation_msg])

	metadata := {
		"resource": asset.name,
		"violation_type": violations,
	}
}

###########################
# Rule Utilities
###########################

# Generate a violation if there is no bucket lifecycle Delete condition and maximum_retention_days is defined.
get_diff[output] {
	input.constraint.spec.parameters.maximum_retention_days != ""
	lifecycle_delete_exists := [is_delete | is_delete = input.asset.resource.data.lifecycle.rule[_].action.type == "Delete"; is_delete = true]
	count(lifecycle_delete_exists) == 0
	output := "Lifecycle delete action does not exist when maximum_retention_days is defined"
}

# Generate a violation if the bucket lifecycle Delete 'age' condition is greater than the maximum_retention_days defined.
get_diff[output] {
	some i
	input.constraint.spec.parameters.maximum_retention_days != ""
	input.asset.resource.data.lifecycle.rule[i].action.type == "Delete"
	lifecycle_age := input.asset.resource.data.lifecycle.rule[i].condition.age
	lifecycle_age > input.constraint.spec.parameters.maximum_retention_days
	output := "Lifecycle age is greater than maximum_retention_days"
}

# Generate a violation if the bucket lifecycle Delete 'age' condition does NOT exist and maximum_retention_days is defined.
get_diff[output] {
	some i
	input.constraint.spec.parameters.maximum_retention_days != ""
	input.asset.resource.data.lifecycle.rule[i].action.type == "Delete"
	lifecycle_age := lib.get_default(input.asset.resource.data.lifecycle.rule[i].condition, "age", "")
	lifecycle_age == ""
	output := "Lifecycle age is not set when maximum_retention_days is defined"
}

# Generate a violation if lifecycle Delete 'age' condition (i.e. retention days) is less than minimum_retention_days
get_diff[output] {
	some i
	input.constraint.spec.parameters.minimum_retention_days != ""
	input.asset.resource.data.lifecycle.rule[i].action.type == "Delete"
	rule_condition := input.asset.resource.data.lifecycle.rule[i].condition
	output := get_min_retention_age_violation(rule_condition, input.constraint.spec.parameters.minimum_retention_days)
}

# lifecycle Delete 'createdBefore' condition is less than minimum_retention_days
get_diff[output] {
	some i
	input.constraint.spec.parameters.minimum_retention_days != ""
	input.asset.resource.data.lifecycle.rule[i].action.type == "Delete"
	rule_condition := input.asset.resource.data.lifecycle.rule[i].condition
	output := get_min_retention_created_before_violation(rule_condition, input.constraint.spec.parameters.minimum_retention_days)
}

# lifecycle Delete 'numNewerVersions' is 0 or does NOT exist when minimum_retention_days is defined
get_diff[output] {
	some i
	input.constraint.spec.parameters.minimum_retention_days != ""
	input.asset.resource.data.lifecycle.rule[i].action.type == "Delete"
	rule_condition := input.asset.resource.data.lifecycle.rule[i].condition
	output := get_min_retention_num_newer_versions_violation(rule_condition, input.constraint.spec.parameters.minimum_retention_days)
}

# Generate a violation if the bucket lifecycle Delete 'age' condition is less than the minimum_retention_days defined.
get_min_retention_age_violation(rule_condition, minimum_retention_days) = output {
	lifecycle_age := rule_condition.age
	lifecycle_age != ""

	lifecycle_age < minimum_retention_days
	output := "Lifecycle age is less than minimum_retention_days"
}

# Generate a violation if the difference between now and the bucket lifecycle Delete 'createdBefore' condition is less than the minimum_retention_days defined.
get_min_retention_created_before_violation(rule_condition, minimum_retention_days) = output {
	created_before := rule_condition.createdBefore
	created_before != ""
	created_before_date_ns := convert_rfc3339_compatible(created_before)
	diff_days := get_diff_in_days_from_now(created_before_date_ns)

	diff_days < minimum_retention_days
	output := "createdBefore condition is less than minimum_retention_days"
}

# Generate a violation if the bucket lifecycle Delete 'numNewerVersions' condition is 0 or does NOT exist when minimum_retention_days is defined.
get_min_retention_num_newer_versions_violation(rule_condition, minimum_retention_days) = output {
	num_newer_versions := lib.get_default(rule_condition, "numNewerVersions", 0)

	num_newer_versions == 0
	output := "numNewerVersions condition is 0 or non-existent"
}

# Convert 'createdBefore' time to ns
convert_rfc3339_compatible(input_time) = converted_ns {
	t_format := "T00:00:00Z"
	input_time_array := [input_time, t_format]
	concat_array := concat("", input_time_array)
	converted_ns := time.parse_rfc3339_ns(concat_array)
}

# Get the difference in days between now and 'createdBefore' time
get_diff_in_days_from_now(time_ns) = diff_in_days {
	ns_in_days := ((((24 * 60) * 60) * 1000) * 1000) * 1000
	time_now_ms := time.now_ns()
	diff_ns := time_now_ms - time_ns
	diff_in_days := round(diff_ns / ns_in_days)
}
