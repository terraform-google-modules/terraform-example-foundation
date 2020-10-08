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

package templates.gcp.GKEClusterVersionConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset
	asset.asset_type == "container.googleapis.com/Cluster"

	mode := lib.get_default(params, "mode", "allowlist")

	# Check if resource is in exempt list
	exempt_list := lib.get_default(params, "exemptions", [])
	not is_exempt(exempt_list, asset.name)

	# Get the version value in the asset
	params_version_type := lib.get_default(params, "version_type", "master")
	target_version_type := get_version_type(params_version_type)
	target_version := get_target_value(asset.resource.data, target_version_type)

	# Check that version is in allowlist/denylist
	asset_version := params.versions
	version_matches := {target_version} & cast_set(asset_version)
	desired_count := target_version_match_count(params.mode)
	count(version_matches) == desired_count

	message := sprintf("Cluster %v has a disallowed %v field", [asset.name, target_version_type])
	metadata := {"resource": asset.name}
}

###########################
# Rule Utilities
###########################

get_version_type(version_type) = target_version {
	version_type == "master"
	target_version := "currentMasterVersion"
}

get_version_type(version_type) = target_version {
	version_type == "node"
	target_version := "currentNodeVersion"
}

is_exempt(exempt_list, asset_name) {
	exempt_list != []
	glob.match(exempt_list[_], ["/"], asset_name)
}

get_target_value(data_resource, field_name) = output {
	output := lib.get_default(data_resource, field_name, "")
}

# Determine the overlap between versions under test and constraint
# By default (allowlist), we violate if there isn't overlap.
target_version_match_count(mode) = 0 {
	mode != "denylist"
}

target_version_match_count(mode) = 1 {
	mode == "denylist"
}
