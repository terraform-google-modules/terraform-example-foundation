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

package templates.gcp.GCPVPCSCProjectPerimeterConstraintV3

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	asset := input.asset

	asset.asset_type == "cloudresourcemanager.googleapis.com/Organization"
	lib.has_field(asset, "service_perimeter")

	lib.get_constraint_params(constraint, params)

	mode := params.mode

	project_number := params.project_number
	service_perimeters := {p | p = params.service_perimeters[_]}

	sprintf("projects/%v", [project_number]) == asset.service_perimeter.status.resources[_]

	perimeter_is_forbidden(mode, asset.service_perimeter.title, service_perimeters)

	message := sprintf("Project %v not allowed in service perimeter %v.", [project_number, asset.service_perimeter.name])
	metadata := {"resource": asset.name, "service_perimeter_name": asset.service_perimeter.name, "project_number": project_number}
}

perimeter_is_forbidden(mode, evaluating_service_perimeter, specified_service_perimeters) {
	mode == "denylist"
	evaluating_service_perimeter == specified_service_perimeters[_]
}

perimeter_is_forbidden(mode, evaluating_service_perimeter, specified_service_perimeters) {
	mode == "allowlist"
	count(specified_service_perimeters) == count(specified_service_perimeters - {evaluating_service_perimeter})
}
