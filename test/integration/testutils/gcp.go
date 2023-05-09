// Copyright 2023 Google LLC
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

import (
	"fmt"

	"github.com/mitchellh/go-testing-interface"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
)

// GetOrgACMPolicyID gets the Organization Access Context Manager Policy ID
func GetOrgACMPolicyID(t testing.TB, orgID string) string {
	filter := fmt.Sprintf("parent:organizations/%s", orgID)
	id := gcloud.Runf(t, "access-context-manager policies list --organization %s --filter %s --quiet", orgID, filter).Array()
	if len(id) == 0 {
		return ""
	}
	return GetLastSplitElement(id[0].Get("name").String(), "/")
}
