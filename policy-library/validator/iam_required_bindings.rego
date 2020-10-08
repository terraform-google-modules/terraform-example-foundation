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

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset

	check_asset_type(asset, params)

	# Check if resource is part of asset names to scan
	include_list := lib.get_default(params, "assetNames", [])
	is_included(include_list, asset.name)

	binding := asset.iam_policy.bindings[_]
	role := binding.role

	params_member := params.members[_]

	glob.match(params.role, ["/"], role)

	no_matches_found := no_required_match(params_member, binding)

	message := sprintf("Required IAM policy member %v is absent in resource %v for role %v", [params_member, asset.name, role])

	metadata := {
		"resource": asset.name,
		"required_member": params_member,
		"role": role,
	}
}

###########################
# Rule Utilities
###########################

# Determine whether the required member is present
no_required_match(params_member, binding) {
	matches_found := [is_required |
		m := config_pattern(params_member)
		is_required := glob.match(m, [], binding.members[_])
	]

	any_required := any(matches_found)
	not any_required
}

check_asset_type(asset, params) {
	lib.has_field(params, "assetType")
	params.assetType == asset.asset_type
}

check_asset_type(asset, params) {
	lib.has_field(params, "assetType") == false
}

is_included(include_list, asset_name) {
	include_list != []
	glob.match(include_list[_], ["/"], asset_name)
}

is_included(include_list, asset_name) {
	include_list == []
}

# If the member in constraint is written as a single "*", turn it into super
# glob "**". Otherwise, we won't be able to match everything.
config_pattern(old_pattern) = "**" {
	old_pattern == "*"
}

config_pattern(old_pattern) = old_pattern {
	old_pattern != "*"
}
