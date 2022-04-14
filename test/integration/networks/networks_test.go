// Copyright 2022 Google LLC
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

package networks

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
)

func getPolicyID(orgID string, t *testing.T) string {
	gcOpts := gcloud.WithCommonArgs([]string{"--format", "value(name)"})
	op := gcloud.Run(t, fmt.Sprintf("access-context-manager policies list --organization=%s ", orgID), gcOpts)
	return op.String()
}

func TestNetworks(t *testing.T) {

	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
	policyID := getPolicyID(orgID, t)

	for _, tt := range []struct {
		name  string
		tfDir string
	}{
		{
			name:  "development",
			tfDir: "../../../3-networks/envs/development",
		},
		{
			name:  "non-production",
			tfDir: "../../../3-networks/envs/non-production",
		},
		{
			name:  "production",
			tfDir: "../../../3-networks/envs/production",
		},
	} {
		t.Run(tt.name, func(t *testing.T) {

			vars := map[string]interface{}{
				"access_context_manager_policy_id": policyID,
			}

			networks := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tt.tfDir),
				tft.WithVars(vars),
			)
			networks.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					networks.DefaultVerify(assert)
				})
			networks.Test()
		})

	}
}
