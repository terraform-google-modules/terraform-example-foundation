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

package templates.gcp.GCPBigQueryTableRetentionConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	lib.get_constraint_params(constraint, params)

	min_retention_days := lib.get_default(params, "minimum_retention_days", "")
	max_retention_days := lib.get_default(params, "maximum_retention_days", "")

	asset := input.asset
	asset.asset_type == "bigquery.googleapis.com/Table"

	# Check if resource is in exempt list
	exempt_list := params.exemptions
	matches := {asset.name} & cast_set(exempt_list)
	count(matches) == 0

	violation_msg := get_diff(asset, min_retention_days, max_retention_days)
	is_string(violation_msg)

	message := sprintf("BigQuery table %v has a retention policy violation: %v", [asset.name, violation_msg])

	metadata := {
		"resource": asset.name,
		"violation_type": violation_msg,
	}
}

###########################
# Rule Utilities
###########################

# Generate a violation if the resource retention is greater than the maximum number of retention days allowed.
get_diff(asset, minimum_retention_days, maximum_retention_days) = output {
	maximum_retention_days != ""
	creation_time := to_number(asset.resource.data.creationTime)
	retention_days_ms := get_ms_of_retention_days(maximum_retention_days)
	get_expiration_time := lib.get_default(asset.resource.data, "expirationTime", "")
	get_expiration_time != ""
	expiration_time := to_number(get_expiration_time)

	diff := expiration_time - creation_time
	diff > retention_days_ms

	output := "BigQuery table retention is greater than maximum_retention_days"
}

# If expirationTime does not exist when looking at the maximum retention, generate a violation.
get_diff(asset, minimum_retention_days, maximum_retention_days) = output {
	maximum_retention_days != ""
	get_expiration_time := lib.get_default(asset.resource.data, "expirationTime", "")
	get_expiration_time == ""

	output := "BigQuery table retention ExpirationTime does not exist"
}

# Generate a violation if the resource retention is less than the minimum number of retention days allowed.
get_diff(asset, minimum_retention_days, maximum_retention_days) = output {
	minimum_retention_days != ""
	creation_time := to_number(asset.resource.data.creationTime)
	retention_days_ms := get_ms_of_retention_days(minimum_retention_days)
	expiration_time := to_number(lib.get_default(asset.resource.data, "expirationTime", retention_days_ms * creation_time))

	diff := expiration_time - creation_time
	diff < retention_days_ms

	output := "BigQuery table retention is less than minimum_retention_days"
}

# Convert retention days to ms as resource data is in ms for better comparison.
get_ms_of_retention_days(retention_days) = retention_days_ms {
	ms_per_day := ((24 * 60) * 60) * 1000
	retention_days_ms := retention_days * ms_per_day
}
