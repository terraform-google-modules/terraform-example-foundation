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

package bootstrap

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/stretchr/testify/assert"
)

func TestOrg(t *testing.T) {


	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../1-org/envs/shared"),
	)

	bootstrap.DefineVerify(
		func(assert *assert.Assertions) {
			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			bootstrap.DefaultVerify(assert)

			auditLogProjectID := bootstrap.GetStringOutput("org_audit_logs_project_id")
			op1 := gcloud.Run(t, fmt.Sprintf("projects describe %s", auditLogProjectID))
			assert.True(op1.Exists(), "project %s does not exist", auditLogProjectID)

			billingLogsProjectID  := bootstrap.GetStringOutput("org_billing_logs_project_id")
			op2 := gcloud.Run(t, fmt.Sprintf("projects describe %s", billingLogsProjectID))
			assert.True(op2.Exists(), "project %s does not exist", billingLogsProjectID)

			secretsProjectID  := bootstrap.GetStringOutput("org_secrets_project_id")
			op3 := gcloud.Run(t, fmt.Sprintf("projects describe %s", secretsProjectID))
			assert.True(op3.Exists(), "project %s does not exist", secretsProjectID)

			interconnectProjectID  := bootstrap.GetStringOutput("interconnect_project_id")
			op4 := gcloud.Run(t, fmt.Sprintf("projects describe %s", interconnectProjectID))
			assert.True(op4.Exists(), "project %s does not exist", interconnectProjectID)

			sccNotificationsProjectID  := bootstrap.GetStringOutput("scc_notifications_project_id")
			op5 := gcloud.Run(t, fmt.Sprintf("projects describe %s", sccNotificationsProjectID))
			assert.True(op5.Exists(), "project %s does not exist", sccNotificationsProjectID)

			dnsHubProjectID  := bootstrap.GetStringOutput("dns_hub_project_id")
			op6 := gcloud.Run(t, fmt.Sprintf("projects describe %s", dnsHubProjectID))
			assert.True(op6.Exists(), "project %s does not exist", dnsHubProjectID)

		})
	bootstrap.Test()
}
