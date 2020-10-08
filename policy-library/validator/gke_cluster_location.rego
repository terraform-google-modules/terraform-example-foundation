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

package templates.gcp.GKEClusterLocationConstraintV3

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)
	asset := input.asset
	asset.asset_type == "container.googleapis.com/Cluster"

	# Check if resource is in exempt list
	exempt_list := params.exemptions
	matches := {asset.name} & cast_set(exempt_list)
	count(matches) == 0

	# Check that location is in allowlist/denylist
	target_location := asset.resource.data.location
	asset_location := params.locations
	location_matches := {target_location} & cast_set(asset_location)
	target_location_match_count(params.mode, desired_count)
	count(location_matches) == desired_count

	message := sprintf("Cluster %v is in a disallowed location", [asset.name])
	metadata := {"resource": asset.name}
}

###########################
# Rule Utilities
###########################

# Determine the overlap between locations under test and constraint
# By default (allowlist), we violate if there isn't overlap.

target_location_match_count(mode) = 0 {
	mode != "denylist"
}

target_location_match_count(mode) = 1 {
	mode == "denylist"
}
