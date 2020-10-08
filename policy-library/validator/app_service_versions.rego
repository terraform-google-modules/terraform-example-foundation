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

package templates.gcp.GCPAppEngineServiceVersionsConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	params := lib.get_constraint_params(constraint)

	# Restrict to App Engine services
	asset := input.asset
	asset.asset_type == "appengine.googleapis.com/Service"

	# Check version count
	max_versions := lib.get_default(params, "max_versions", 2)
	version_count := count(asset.resource.data.split.allocations)
	version_count > max_versions

	message := sprintf("%v has more than %v versions (%v).", [asset.name, max_versions, version_count])
	metadata := {
		"constraint": params,
		"resource": asset.name,
	}
}
