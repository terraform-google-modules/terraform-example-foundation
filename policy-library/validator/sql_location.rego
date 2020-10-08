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

package templates.gcp.GCPSQLLocationConstraintV1

import data.validator.gcp.lib as lib

############################################
# Find Cloud SQL Location Violations
############################################
deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)

	# Verify that resource is Cloud SQL instance
	asset := input.asset
	asset.asset_type == "sqladmin.googleapis.com/Instance"

	# Check if resource is in exempt list
	exempt_list := lib.get_default(params, "exemptions", [])
	matches := {asset.name} & cast_set(exempt_list)
	count(matches) == 0

	# Check that location is in allowlist/denylist
	target_locations := params.locations
	asset_location := asset.resource.data.region
	location_matches := {asset_location} & cast_set(target_locations)
	target_location_match_count(params.mode, desired_count)
	count(location_matches) == desired_count

	message := sprintf("%v is in a disallowed location (%v).", [asset.name, asset_location])
	metadata := {"location": asset_location, "resource": asset.name}
}

#################
# Rule Utilities
#################

# Determine the overlap between locations under test and constraint
# By default (allowlist), we violate if there isn't overlap
target_location_match_count(mode) = 0 {
	mode != "denylist"
}

target_location_match_count(mode) = 1 {
	mode == "denylist"
}
