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
	"os"
	"os/exec"
	"path"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/tidwall/gjson"
)

// getResultFieldStrSlice parses a field of a results list into a string slice
func getResultFieldStrSlice(rs []gjson.Result, field string) []string {
	s := make([]string, 0)
	for _, r := range rs {
		s = append(s, r.Get(field).String())
	}
	return s
}

// fileExists check if a give file exists
func fileExists(filePath string) (bool, error) {
	_, err := os.Stat(filePath)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

func TestBootstrap(t *testing.T) {

	vars := map[string]interface{}{
		"tfstate_storage_force_destroy": "true",
	}

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
		tft.WithVars(vars),
	)

	cloudSourceRepos := []string{
		"gcp-org",
		"gcp-environments",
		"gcp-networks",
		"gcp-projects",
		"gcp-policies",
	}

	triggerRepos := []string{
		"gcp-org",
		"gcp-environments",
		"gcp-networks",
		"gcp-projects",
	}

	branchesRegex := `^(development|non\\-production|production)$`

	activateApis := []string{
		"serviceusage.googleapis.com",
		"servicenetworking.googleapis.com",
		"compute.googleapis.com",
		"logging.googleapis.com",
		"bigquery.googleapis.com",
		"cloudresourcemanager.googleapis.com",
		"cloudbilling.googleapis.com",
		"iam.googleapis.com",
		"admin.googleapis.com",
		"appengine.googleapis.com",
		"storage-api.googleapis.com",
		"monitoring.googleapis.com",
		"pubsub.googleapis.com",
		"securitycenter.googleapis.com",
		"accesscontextmanager.googleapis.com",
	}

	bootstrap.DefineApply(
		func(assert *assert.Assertions){

			bootstrap.DefaultApply(assert)
			// configure options to push state to GCS bucket
			tempOptions := bootstrap.GetTFOptions()
			tempOptions.BackendConfig = map[string]interface{}{
				"bucket": bootstrap.GetStringOutput("gcs_bucket_tfstate"),
			}
			tempOptions.MigrateState = true
			// create backend file
			cwd, err := os.Getwd()
			require.NoError(t, err)
			destFile := path.Join(cwd, "../../../0-bootstrap/backend.tf")
			fExists, err2 := fileExists(destFile)
			require.NoError(t, err2)
			if !fExists {
				srcFile := path.Join(cwd, "../../../0-bootstrap/backend.tf.example")
				_, err3 := exec.Command("cp", srcFile, destFile).CombinedOutput()
				require.NoError(t, err3)
			}
			terraform.Init(t, tempOptions)
		})

	bootstrap.DefineVerify(
		func(assert *assert.Assertions) {

			// cloud build project
			cbProjectID := bootstrap.GetStringOutput("cloudbuild_project_id")
			bucketName := bootstrap.GetStringOutput("gcs_bucket_cloudbuild_artifacts")

			prj := gcloud.Runf(t, "projects describe %s", cbProjectID)
			assert.True(prj.Exists(), "project %s should exist", cbProjectID)

			gcAlphaOpts := gcloud.WithCommonArgs([]string{"--project", cbProjectID, "--json"})
			bkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName), gcAlphaOpts).Array()[0]
			assert.True(bkt.Exists(), "bucket %s should exist", bucketName)

			for _, repo := range cloudSourceRepos {
				sourceRepoFullName := fmt.Sprintf("projects/%s/repos/%s", cbProjectID, repo)
				sourceRepo := gcloud.Runf(t, "source repos describe %s --project %s", repo, cbProjectID)
				assert.Equal(sourceRepoFullName, sourceRepo.Get("name").String(), fmt.Sprintf("repository %s should exist", repo))
			}

			for _, triggerRepo := range triggerRepos {
				for _, filter := range []string{
					fmt.Sprintf("trigger_template.branch_name='%s' AND  trigger_template.repo_name='%s' AND substitutions._TF_ACTION='apply'", branchesRegex, triggerRepo),
					fmt.Sprintf("trigger_template.branch_name='%s' AND  trigger_template.repo_name='%s' AND substitutions._TF_ACTION='plan' AND trigger_template.invert_regex=true", branchesRegex, triggerRepo),
				} {
					cbOpts := gcloud.WithCommonArgs([]string{"--project", cbProjectID, "--filter", filter, "--format", "json"})
					cbTriggers := gcloud.Run(t, "beta builds triggers list", cbOpts).Array()
					assert.Equal(1, len(cbTriggers), fmt.Sprintf("cloud builds trigger with filter %s should exist", filter))
				}
			}

			// seed project
			seedProjectID := bootstrap.GetStringOutput("seed_project_id")
			tfStateBucketName := bootstrap.GetStringOutput("gcs_bucket_tfstate")

			seedPrj := gcloud.Runf(t, "projects describe %s", seedProjectID)
			assert.True(seedPrj.Exists(), "project %s should exist", seedProjectID)

			enabledAPIS := gcloud.Runf(t, "services list --project %s", seedProjectID).Array()
			listApis := getResultFieldStrSlice(enabledAPIS, "config.name")
			assert.Subset(listApis, activateApis, "APIs should have been enabled")

			seedAlphaOpts := gcloud.WithCommonArgs([]string{"--project", seedProjectID, "--json"})
			tfStateBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", tfStateBucketName), seedAlphaOpts).Array()[0]
			assert.True(tfStateBkt.Exists(), "bucket %s should exist", tfStateBucketName)

			for _, sa := range []struct {
				output   string
				orgRoles []string
			}{
				{
					output: "terraform_service_account",
				},
				{
					output: "projects_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/accesscontextmanager.policyAdmin",
						"roles/serviceusage.serviceUsageConsumer",
					},
				},
				{
					output: "networks_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/accesscontextmanager.policyAdmin",
						"roles/compute.xpnAdmin",
					},
				},
				{
					output: "environment_step_terraform_service_account_email",
				},
				{
					output: "organization_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/orgpolicy.policyAdmin",
						"roles/logging.configWriter",
						"roles/resourcemanager.organizationAdmin",
						"roles/securitycenter.notificationConfigEditor",
						"roles/resourcemanager.organizationViewer",
						"roles/accesscontextmanager.policyAdmin",
					},
				},
			} {
				terraformSAEmail := bootstrap.GetStringOutput(sa.output)
				terraformSAName := fmt.Sprintf("projects/%s/serviceAccounts/%s", seedProjectID, terraformSAEmail)
				terraformSA := gcloud.Runf(t, "iam service-accounts describe %s --project %s", terraformSAEmail, seedProjectID)
				assert.Equal(terraformSAName, terraformSA.Get("name").String(), fmt.Sprintf("service account %s should exist", terraformSAEmail))

				iamFilter := fmt.Sprintf("bindings.members:'serviceAccount:%s'", terraformSAEmail)
				iamOpts := gcloud.WithCommonArgs([]string{"--flatten", "bindings", "--filter", iamFilter, "--format", "json"})
				orgID := bootstrap.GetTFSetupStringOutput("org_id")
				orgIamPolicyRoles := gcloud.Run(t, fmt.Sprintf("organizations get-iam-policy %s", orgID), iamOpts).Array()
				listRoles := getResultFieldStrSlice(orgIamPolicyRoles, "bindings.role")
				if len(sa.orgRoles) == 0 {
					assert.Empty(listRoles, fmt.Sprintf("service account %s should not have organization level roles", terraformSAEmail))
				} else {
					assert.Subset(listRoles, sa.orgRoles, fmt.Sprintf("service account %s should have organization level roles", terraformSAEmail))
				}
			}
		})

	bootstrap.DefineTeardown(func(assert *assert.Assertions) {
		// configure options to pull state from GCS bucket
		cwd, err := os.Getwd()
		require.NoError(t, err)
		statePath := path.Join(cwd, "../../../0-bootstrap/local_backend.tfstate")
		tempOptions := bootstrap.GetTFOptions()
		tempOptions.BackendConfig = map[string]interface{}{
			"path": statePath,
		}
		tempOptions.MigrateState = true
		// remove backend file
		backendFile := path.Join(cwd, "../../../0-bootstrap/backend.tf")
		fExists, err2 := fileExists(backendFile)
		require.NoError(t, err2)
		if fExists {
			_, err3 := exec.Command("rm", backendFile).CombinedOutput()
			require.NoError(t, err3)
		}
		terraform.Init(t, tempOptions)
		bootstrap.DefaultTeardown(assert)
	})
	bootstrap.Test()
}
