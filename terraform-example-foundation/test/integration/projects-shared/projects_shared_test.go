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
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
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
		repo  string
		tfDir string
	}{
		{
			name:  "bu1",
			repo:  "bu1-example-app",
			tfDir: "../../../4-projects/business_unit_1/shared",
		},
		{
			name:  "bu2",
			repo:  "bu2-example-app",
			tfDir: "../../../4-projects/business_unit_2/shared",
		},
	} {
		t.Run(tts.name, func(t *testing.T) {

			sharedVars := map[string]interface{}{
				"remote_state_bucket": backend_bucket,
			}

			shared := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(tts.tfDir),
				tft.WithVars(sharedVars),
				tft.WithBackendConfig(backendConfig),
				tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 1, 2*time.Minute),
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

					// validate buckets
					gcAlphaOpts := gcloud.WithCommonArgs([]string{"--project", projectID, "--json"})
					artifactBktName := terraform.OutputMap(t, shared.GetTFOptions(), "artifact_buckets")[tts.repo]
					artifactBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", artifactBktName), gcAlphaOpts).Array()[0]
					assert.True(artifactBkt.Exists(), "bucket %s should exist", artifactBktName)
					assert.Equal(artifactBktName, fmt.Sprintf("bkt-%s-%s-artifacts", projectID, tts.repo))

					logBktName := terraform.OutputMap(t, shared.GetTFOptions(), "log_buckets")[tts.repo]
					logBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", logBktName), gcAlphaOpts).Array()[0]
					assert.True(logBkt.Exists(), "bucket %s should exist", logBktName)
					assert.Equal(logBktName, fmt.Sprintf("bkt-%s-%s-logs", projectID, tts.repo))

					stateBktName := terraform.OutputMap(t, shared.GetTFOptions(), "state_buckets")[tts.repo]
					stateBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", stateBktName), gcAlphaOpts).Array()[0]
					assert.True(stateBkt.Exists(), "bucket %s should exist", stateBktName)
					assert.Equal(stateBktName, fmt.Sprintf("bkt-%s-%s-state", projectID, tts.repo))
				})
			shared.Test()
		})

	}
}
