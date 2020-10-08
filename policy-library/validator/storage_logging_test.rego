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

package templates.gcp.GCPStorageLoggingConstraintV1

all_violations[violation] {
	resource := data.test.fixtures.storage_logging.assets[_]
	constraint := data.test.fixtures.storage_logging.constraints.require_storage_logging

	issues := deny with input.asset as resource
		 with input.constraint as constraint

	violation := issues[_]
}

# Confirm total violations count
test_storage_logging_violations_count {
	count(all_violations) == 1
}

test_storage_logging_violations_basic {
	violation := all_violations[_]
	violation.details.resource == "//storage.googleapis.com/my-storage-bucket"
}
