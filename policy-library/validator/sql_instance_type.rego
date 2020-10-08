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

package templates.gcp.GCPSQLInstanceTypeConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	asset := input.asset
	constraint := input.constraint

	asset.asset_type == "sqladmin.googleapis.com/Instance"
	resource := asset.resource.data

	resource.instanceType == "CLOUD_SQL_INSTANCE"
	lib.get_constraint_params(constraint, params)

	mode := lib.get_default(params, "mode", "deny")

	not is_sql_instance_type_allowed(resource, mode, params)

	message := sprintf("%v is not allowed to have an instance type of %s.", [asset.name, resource.databaseVersion])
	metadata := {"resource": input.asset.name}
}

is_sql_instance_type_allowed(resource, mode, params) {
	mode == "allow"
	any_match(params.sql_instance_types, resource.databaseVersion)
}

is_sql_instance_type_allowed(resource, mode, params) {
	mode == "deny"
	not any_match(params.sql_instance_types, resource.databaseVersion)
}

any_match(instance_types, resource_type) {
	instance_type := instance_types[_]
	re_match(sprintf("^%s.*$", [instance_type]), resource_type)
}
