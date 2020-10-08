#
# Copyright 2018 Google LLC
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

package templates.gcp.GCPStorageBucketPolicyOnlyConstraintV1

import data.validator.gcp.lib as lib

deny[{
	"msg": message,
	"details": metadata,
}] {
	constraint := input.constraint
	asset := input.asset
	asset.asset_type == "storage.googleapis.com/Bucket"

	bucket := asset.resource.data
	bucket_policy_enabled(bucket) != true

	message := sprintf("%v does not have bucket policy only enabled.", [asset.name])
	metadata := {"resource": asset.name}
}

###########################
# Rule Utilities
###########################
bucket_policy_enabled(bucket) = bucket_policy_enabled {
	iam_configuration := lib.get_default(bucket, "iamConfiguration", {})
	bucket_policy_only := lib.get_default(iam_configuration, "bucketPolicyOnly", {})
	bucket_policy_enabled := lib.get_default(bucket_policy_only, "enabled", null)
}
