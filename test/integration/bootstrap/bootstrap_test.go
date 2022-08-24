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
	"time"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func TestBootstrap(t *testing.T) {

	vars := map[string]interface{}{
		"bucket_force_destroy": true,
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
		"tf-cloudbuilder",
		"gcp-bootstrap",
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

	orgID := utils.ValFromEnv(t, "TF_VAR_org_id")

	bootstrap.DefineApply(
		func(assert *assert.Assertions) {
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
		})

	bootstrap.DefineVerify(
		func(assert *assert.Assertions) {

			// cloud build project
			cbProjectID := bootstrap.GetStringOutput("cloudbuild_project_id")
			bucketName := terraform.OutputMap(t, bootstrap.GetTFOptions(), "gcs_bucket_cloudbuild_artifacts")

			prj := gcloud.Runf(t, "projects describe %s", cbProjectID)
			assert.True(prj.Exists(), "project %s should exist", cbProjectID)

			for _, env := range []string{
				"org",
				"env",
				"net",
				"proj",
			} {
				gcAlphaOpts := gcloud.WithCommonArgs([]string{"--project", cbProjectID, "--json"})
				bkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", bucketName[env]), gcAlphaOpts).Array()[0]
				assert.True(bkt.Exists(), "bucket %s should exist", bucketName[env])
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
				orgIamPolicyRoles := gcloud.Run(t, fmt.Sprintf("organizations get-iam-policy %s", orgID), iamOpts).Array()
				listRoles := testutils.GetResultFieldStrSlice(orgIamPolicyRoles, "bindings.role")
				if len(sa.orgRoles) == 0 {
					assert.Empty(listRoles, fmt.Sprintf("service account %s should not have organization level roles", terraformSAEmail))
				} else {
					assert.Subset(listRoles, sa.orgRoles, fmt.Sprintf("service account %s should have organization level roles", terraformSAEmail))
				}
			}
		})
	bootstrap.Test()
}
