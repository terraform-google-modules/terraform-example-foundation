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

package projectsshared

import (
	"fmt"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func TestProjectsShared(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	// Configure impersonation for test execution
	terraformSA := bootstrap.GetStringOutput("projects_step_terraform_service_account_email")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)

	backend_bucket := bootstrap.GetStringOutput("gcs_bucket_tfstate")
	projects_backend_bucket := bootstrap.GetStringOutput("projects_gcs_bucket_tfstate")
	backendConfig := map[string]interface{}{
		"bucket": projects_backend_bucket,
	}

	var sharedApisEnabled = []string{
		"cloudbuild.googleapis.com",
		"sourcerepo.googleapis.com",
		"cloudkms.googleapis.com",
	}

	for _, tts := range []struct {
		name  string
		tfDir string
	}{
		{
			name:  "bu1",
			tfDir: "../../../4-projects/business_unit_1/shared",
		},
		{
			name:  "bu2",
			tfDir: "../../../4-projects/business_unit_2/shared",
		},
	} {
		t.Run(tts.name, func(t *testing.T) {

			sharedVars := map[string]interface{}{
				"backend_bucket":              backend_bucket,
			}

			shared := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tts.tfDir),
				tft.WithVars(sharedVars),
				tft.WithBackendConfig(backendConfig),
				tft.WithPolicyLibraryPath("/workspace/policy-library", bootstrap.GetTFSetupStringOutput("project_id")),
			)

			shared.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					shared.DefaultVerify(assert)

					projectID := shared.GetStringOutput("cloudbuild_project_id")
					prj := gcloud.Runf(t, "projects describe %s", projectID)
					assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

					enabledAPIS := gcloud.Runf(t, "services list --project %s", projectID).Array()
					listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
					assert.Subset(listApis, sharedApisEnabled, "APIs should have been enabled")
				})
			shared.Test()
		})

	}
}
