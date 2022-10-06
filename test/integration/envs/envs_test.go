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

package envs

import (
	"fmt"
	"testing"
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func TestEnvs(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	// Configure impersonation for test execution
	terraformSA := bootstrap.GetStringOutput("environment_step_terraform_service_account_email")
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)

	backend_bucket := bootstrap.GetStringOutput("gcs_bucket_tfstate")
	monitoringWorkspaceUsers := bootstrap.GetTFSetupStringOutput("monitoring_workspace_users")

	vars := map[string]interface{}{
		"remote_state_bucket":        backend_bucket,
		"monitoring_workspace_users": monitoringWorkspaceUsers,
	}

	backendConfig := map[string]interface{}{
		"bucket": backend_bucket,
	}

	for _, envName := range []string{
		"development",
		"non-production",
		"production",
	} {
		t.Run(envName, func(t *testing.T) {
			envs := tft.NewTFBlueprintTest(t,
				tft.WithTFDir(fmt.Sprintf("../../../2-environments/envs/%s", envName)),
				tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 1, 2*time.Minute),
				tft.WithPolicyLibraryPath("/workspace/policy-library", bootstrap.GetTFSetupStringOutput("project_id")),
				tft.WithVars(vars),
				tft.WithBackendConfig(backendConfig),
			)
			envs.DefineVerify(
				func(assert *assert.Assertions) {
					// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
					envs.DefaultVerify(assert)

					envFolder := testutils.GetLastSplitElement(envs.GetStringOutput("env_folder"), "/")
					folder := gcloud.Runf(t, "resource-manager folders describe %s", envFolder)
					displayName := fmt.Sprintf("fldr-%s", envName)
					assert.Equal(displayName, folder.Get("displayName").String(), fmt.Sprintf("folder %s should have been created", displayName))

					// check tags applied to environment folder
					envFldrTags := gcloud.Runf(t, "resource-manager tags bindings list --parent=//cloudresourcemanager.googleapis.com/folders/%s", envFolder).Array()

					fldrTagValueId := testutils.GetResultFieldStrSlice(envFldrTags, "tagValue")

					var fldrTagValue []string
					for _, tagValueId := range fldrTagValueId {
						tagValueObj := gcloud.Runf(t, "resource-manager tags values describe %s", tagValueId)
						fldrTagValue = append(fldrTagValue, tagValueObj.Get("shortName").String())
					}
					assert.Subset([]string{envName}, fldrTagValue, fmt.Sprintf("tag value should be %s for %s env folder", envName, envName))

					for _, projectEnvOutput := range []struct {
						projectOutput string
						role          string
						group         string
						apis          []string
					}{
						{
							projectOutput: "monitoring_project_id",
							role:          "roles/monitoring.editor",
							group:         monitoringWorkspaceUsers,
							apis: []string{
								"logging.googleapis.com",
								"monitoring.googleapis.com",
								"billingbudgets.googleapis.com",
							},
						},
						{
							projectOutput: "base_shared_vpc_project_id",
							apis: []string{
								"compute.googleapis.com",
								"dns.googleapis.com",
								"servicenetworking.googleapis.com",
								"container.googleapis.com",
								"logging.googleapis.com",
								"billingbudgets.googleapis.com",
							},
						},
						{
							projectOutput: "restricted_shared_vpc_project_id",
							apis: []string{
								"compute.googleapis.com",
								"dns.googleapis.com",
								"servicenetworking.googleapis.com",
								"container.googleapis.com",
								"logging.googleapis.com",
								"cloudresourcemanager.googleapis.com",
								"accesscontextmanager.googleapis.com",
								"billingbudgets.googleapis.com",
							},
						},
						{
							projectOutput: "env_secrets_project_id",
							apis: []string{
								"secretmanager.googleapis.com",
								"logging.googleapis.com",
							},
						},
					} {
						projectID := envs.GetStringOutput(projectEnvOutput.projectOutput)
						prj := gcloud.Runf(t, "projects describe %s", projectID)
						assert.Equal(projectID, prj.Get("projectId").String(), fmt.Sprintf("project %s should exist", projectID))
						assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

						enabledAPIS := gcloud.Runf(t, "services list --project %s", projectID).Array()
						listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
						assert.Subset(listApis, projectEnvOutput.apis, "APIs should have been enabled")

						if projectEnvOutput.role != "" {
							iamOpts := gcloud.WithCommonArgs([]string{"--flatten", "bindings", "--filter", fmt.Sprintf("bindings.role:%s", projectEnvOutput.role), "--format", "json"})
							iamPolicy := gcloud.Run(t, fmt.Sprintf("projects get-iam-policy %s", projectID), iamOpts).Array()[0]
							listMembers := utils.GetResultStrSlice(iamPolicy.Get("bindings.members").Array())
							assert.Contains(listMembers, fmt.Sprintf("group:%s", projectEnvOutput.group), fmt.Sprintf("group %s should have role %s", projectEnvOutput.group, projectEnvOutput.role))
						}
					}

				})
			envs.Test()
		})

	}
}
