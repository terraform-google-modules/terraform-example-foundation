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
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

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
		"bucket_force_destroy":             true,
		"bucket_tfstate_kms_force_destroy": true,
	}

	temp := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
		tft.WithVars(vars),
		tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 1, 2*time.Minute),
		tft.WithPolicyLibraryPath("/workspace/policy-library", temp.GetTFSetupStringOutput("project_id")),
	)

	cloudSourceRepos := []string{
		"gcp-org",
		"gcp-environments",
		"gcp-networks",
		"gcp-projects",
		"gcp-policies",
		"tf-cloudbuilder",
		"gcp-bootstrap",
	}

	triggerRepos := []string{
		"gcp-bootstrap",
		"gcp-org",
		"gcp-environments",
		"gcp-networks",
		"gcp-projects",
	}

	branchesRegex := `^(development|nonproduction|production)$`

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
		func(assert *assert.Assertions) {
			// check APIs
			projectID := bootstrap.GetTFSetupStringOutput("project_id")
			for _, api := range []string{
				"cloudresourcemanager.googleapis.com",
				"cloudbilling.googleapis.com",
				"iam.googleapis.com",
				"storage-api.googleapis.com",
				"serviceusage.googleapis.com",
				"cloudbuild.googleapis.com",
				"sourcerepo.googleapis.com",
				"cloudkms.googleapis.com",
				"bigquery.googleapis.com",
				"accesscontextmanager.googleapis.com",
				"securitycenter.googleapis.com",
				"servicenetworking.googleapis.com",
				"billingbudgets.googleapis.com",
			} {
				utils.Poll(t, func() (bool, error) { return testutils.CheckAPIEnabled(t, projectID, api) }, 5, 2*time.Minute)
			}

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
			artifactsBktName := terraform.OutputMap(t, bootstrap.GetTFOptions(), "gcs_bucket_cloudbuild_artifacts")
			logsBktName := terraform.OutputMap(t, bootstrap.GetTFOptions(), "gcs_bucket_cloudbuild_logs")
			defaultRegion := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["default_region"]

			prj := gcloud.Runf(t, "projects describe %s", cbProjectID)
			assert.True(prj.Exists(), "project %s should exist", cbProjectID)

			// Private Pools
			workerPoolName := testutils.GetLastSplitElement(bootstrap.GetStringOutput("cloud_build_private_worker_pool_id"), "/")
			peeredNetworkName := testutils.GetLastSplitElement(bootstrap.GetStringOutput("cloud_build_peered_network_id"), "/")
			pool := gcloud.Runf(t, "builds worker-pools describe %s --region %s --project %s", workerPoolName, defaultRegion, cbProjectID)
			assert.Equal(workerPoolName, pool.Get("name").String(), "pool %s should exist", workerPoolName)
			assert.Equal("PUBLIC_EGRESS", pool.Get("privatePoolV1Config.networkConfig.egressOption").String(), "pool %s should have internet access", workerPoolName)
			assert.Equal("e2-medium", pool.Get("privatePoolV1Config.workerConfig.machineType").String(), "pool %s should have the configured machineType", workerPoolName)
			assert.Equal("100", pool.Get("privatePoolV1Config.workerConfig.diskSizeGb").String(), "pool %s should have the configured disk size", workerPoolName)
			assert.Equal(peeredNetworkName, testutils.GetLastSplitElement(pool.Get("privatePoolV1Config.networkConfig.peeredNetwork").String(), "/"), "pool %s should have peered network configured", workerPoolName)

			globalAddressName := "ga-b-cbpools-worker-pool-range"
			globalAddress := gcloud.Runf(t, "compute addresses describe %s --global --project %s", globalAddressName, cbProjectID)
			assert.Equal(globalAddressName, globalAddress.Get("name").String(), fmt.Sprintf("global address %s should exist", globalAddressName))
			assert.Equal("VPC_PEERING", globalAddress.Get("purpose").String(), fmt.Sprintf("global address %s purpose should be VPC peering", globalAddressName))
			assert.Equal(peeredNetworkName, testutils.GetLastSplitElement(globalAddress.Get("network").String(), "/"), fmt.Sprintf("global address %s should be in the peered network", globalAddressName))

			for _, bkts := range []struct {
				env  string
				repo string
			}{
				{
					env:  "bootstrap",
					repo: "gcp-bootstrap",
				},
				{
					env:  "org",
					repo: "gcp-org",
				},
				{
					env:  "env",
					repo: "gcp-environments",
				},
				{
					env:  "net",
					repo: "gcp-networks",
				},
				{
					env:  "proj",
					repo: "gcp-projects",
				},
			} {
				gcAlphaOpts := gcloud.WithCommonArgs([]string{"--project", cbProjectID, "--json"})
				artifactsBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", artifactsBktName[bkts.env]), gcAlphaOpts).Array()[0]
				assert.True(artifactsBkt.Exists(), "bucket %s should exist", artifactsBktName[bkts.env])
				assert.Equal(artifactsBktName[bkts.env], fmt.Sprintf("bkt-%s-%s-build-artifacts", cbProjectID, bkts.repo))

				logsBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", logsBktName[bkts.env]), gcAlphaOpts).Array()[0]
				assert.True(logsBkt.Exists(), "bucket %s should exist", logsBktName[bkts.env])
				assert.Equal(logsBktName[bkts.env], fmt.Sprintf("bkt-%s-%s-build-logs", cbProjectID, bkts.repo))
			}

			for _, repo := range cloudSourceRepos {
				sourceRepoFullName := fmt.Sprintf("projects/%s/repos/%s", cbProjectID, repo)
				sourceRepo := gcloud.Runf(t, "source repos describe %s --project %s", repo, cbProjectID)
				assert.Equal(sourceRepoFullName, sourceRepo.Get("name").String(), fmt.Sprintf("repository %s should exist", repo))
			}

			for _, triggerRepo := range triggerRepos {
				for _, filter := range []string{
					fmt.Sprintf("trigger_template.branch_name='%s' AND  trigger_template.repo_name='%s' AND name='%s-apply'", branchesRegex, triggerRepo, triggerRepo),
					fmt.Sprintf("trigger_template.branch_name='%s' AND  trigger_template.repo_name='%s' AND name='%s-plan' AND trigger_template.invert_regex=true", branchesRegex, triggerRepo, triggerRepo),
				} {
					cbOpts := gcloud.WithCommonArgs([]string{"--project", cbProjectID, "--region", defaultRegion, "--filter", filter, "--format", "json"})
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
			listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
			assert.Subset(listApis, activateApis, "APIs should have been enabled")

			seedAlphaOpts := gcloud.WithCommonArgs([]string{"--project", seedProjectID, "--json"})
			tfStateBkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", tfStateBucketName), seedAlphaOpts).Array()[0]
			assert.True(tfStateBkt.Exists(), "bucket %s should exist", tfStateBucketName)

			for _, sa := range []struct {
				output   string
				orgRoles []string
			}{
				{
					output: "projects_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/accesscontextmanager.policyAdmin",
						"roles/resourcemanager.organizationAdmin",
						"roles/serviceusage.serviceUsageConsumer",
						"roles/browser",
					},
				},
				{
					output: "networks_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/accesscontextmanager.policyAdmin",
						"roles/compute.xpnAdmin",
						"roles/browser",
					},
				},
				{
					output: "environment_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/browser",
					},
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
						"roles/browser",
					},
				},
				{
					output: "bootstrap_step_terraform_service_account_email",
					orgRoles: []string{
						"roles/resourcemanager.organizationAdmin",
						"roles/accesscontextmanager.policyAdmin",
						"roles/serviceusage.serviceUsageConsumer",
						"roles/browser",
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
				listRoles := testutils.GetResultFieldStrSlice(orgIamPolicyRoles, "bindings.role")
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
