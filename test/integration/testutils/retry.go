// Copyright 2022-2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package testutils

var (
	RetryableTransientErrors = map[string]string{
		// Error 400: There is a peering operation in progress on the local or peer network.
		".*Error 400.*There is a peering operation in progress on the local or peer network.*": "Peering operation in progress.",

		// Error code 409 for concurrent policy changes.
		".*Error 409.*There were concurrent policy changes.*": "Concurrent policy changes.",

		// API Rate limit exceeded errors can be retried.
		".*rateLimitExceeded.*": "Rate limit exceeded.",

		// Project deletion is eventually consistent. Even if google_project resources inside the folder are deleted there may be a deletion error.
		".*FOLDER_TO_DELETE_NON_EMPTY_VIOLATION.*": "Failed to delete non empty folder.",

		// Granting IAM Roles is eventually consistent.
		".*Error 403.*Permission.*denied on resource.*": "Permission denied on resource.",

		// Editing VPC Service Controls is eventually consistent.
		".*Error 403.*Request is prohibited by organization's policy.*vpcServiceControlsUniqueIdentifier.*": "Request is prohibited by organization's policy.",

		// Error code 13 during the creation of a Resource Manager Tag Value.
		".*Error getting operation for committing purpose for TagValue.*": "Failed creating TagValue.",

		// Error 403: Compute Engine API has not been used in project {} before or it is disabled.
		".*Error 403.*Compute Engine API has not been used in project.*": "Compute Engine API not enabled",
	}
)
