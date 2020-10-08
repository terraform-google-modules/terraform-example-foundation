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

package templates.gcp.GCPVPCSCAllowedRegionsConstraintV2

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	asset := input.asset

	asset.asset_type == "cloudresourcemanager.googleapis.com/Organization"
	lib.has_field(asset, "access_level")

	lib.get_constraint_params(constraint, params)

	regions := cast_set(lib.get_default(asset.access_level.basic.conditions[_], "regions", []))

	allowed_regions := cast_set(params.regions)

	test_region := regions[_]

	count({test_region} & allowed_regions) == 0

	message := sprintf("Region %v is not allowed in access level %v", [test_region, asset.access_level.name])
	metadata := {"resource": asset.name, "access_level_name": asset.access_level.name}
}
