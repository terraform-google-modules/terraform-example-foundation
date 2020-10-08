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

package templates.gcp.GCPIAMAuditLogConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	asset_types := {
		"cloudresourcemanager.googleapis.com/Organization",
		"cloudresourcemanager.googleapis.com/Folder",
		"cloudresourcemanager.googleapis.com/Project",
	}

	input.asset.asset_type == asset_types[_]
	count(expected_audit_configs) == 0
	lib.get_constraint_params(input.constraint, params)
	message := sprintf("IAM policy for %v does not have correct audit logs enabled in service(s) %v", [input.asset.name, params.services])

	metadata := {"resource": input.asset.name}
}

evaluate_allowed_exemptions(params, exempted_members) = result {
	not params.allowed_exemptions
	result = true
}

evaluate_allowed_exemptions(params, exempted_members) = result {
	got_exemptions := {e | e = exempted_members[_]}
	want_exemptions := {e | e = params.allowed_exemptions[_]}
	unexpected_exemptions := got_exemptions - want_exemptions
	result = count(unexpected_exemptions) == 0
}

expected_audit_configs[config] {
	configs := lib.get_default(input.asset.iam_policy, "audit_configs", {})
	config := configs[_]
	lib.get_constraint_params(input.constraint, params)
	config.service == params.services[_]
	log_type_map := {
		"ADMIN_READ": 1,
		"DATA_WRITE": 2,
		"DATA_READ": 3,
	}

	got_log_types := {t | t = config.audit_log_configs[_].log_type}
	want_log_types := {t | t = log_type_map[params.log_types[_]]}
	missing_log_types := want_log_types - got_log_types

	count(missing_log_types) == 0
	evaluate_allowed_exemptions(params, config.audit_log_configs[_].exempted_members)
}
