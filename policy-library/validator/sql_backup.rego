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

package templates.gcp.GCPSQLBackupConstraintV1

import data.validator.gcp.lib as lib

# A violation is generated only when the rule body evaluates to true.
deny[{
	"msg": message,
	"details": metadata,
}] {
	# by default any hour accepted
	spec := lib.get_default(input.constraint, "spec", "")
	parameters := lib.get_default(spec, "parameters", "")
	exempt_list := lib.get_default(parameters, "exemptions", [])

	asset := input.asset
	asset.asset_type == "sqladmin.googleapis.com/Instance"

	# Check if resource is in exempt list
	matches := {asset.name} & cast_set(exempt_list)
	count(matches) == 0

	# get instance settings
	settings := lib.get_default(asset.resource.data, "settings", {})
	instance_backupConfiguration := lib.get_default(settings, "backupConfiguration", {})
	instance_backupConfiguration_enabled := lib.get_default(instance_backupConfiguration, "enabled", "")

	# check compliance
	instance_backupConfiguration_enabled != true

	message := sprintf("%v backup not enabled'", [asset.name])
	metadata := {"resource": asset.name}
}
