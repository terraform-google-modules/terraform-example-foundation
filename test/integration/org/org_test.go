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

package org

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestOrg(t *testing.T) {

	org := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../1-org/envs/shared"),
	)

	org.DefineVerify(
		func(assert *assert.Assertions) {
			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			org.DefaultVerify(assert)

			for _, projectOutput := range []string {
				"org_audit_logs_project_id",
				"org_billing_logs_project_id",
				"org_secrets_project_id",
				"interconnect_project_id",
				"scc_notifications_project_id",
				"dns_hub_project_id",
			} {
				projectID := org.GetStringOutput(projectOutput)
				op := gcloud.Run(t, fmt.Sprintf("projects describe %s", projectID))
				assert.True(op.Exists(), "project %s should exist", projectID)
			}
		})
	org.Test()
}
