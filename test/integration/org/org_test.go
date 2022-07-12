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
	"strings"
	"testing"

	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/gcloud"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/tft"
	"github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test/pkg/utils"
	"github.com/stretchr/testify/assert"
	"github.com/tidwall/gjson"
)

func isHubAndSpoke(t *testing.T) bool {
	return "HubAndSpoke" == utils.ValFromEnv(t, "TF_VAR_example_foundations_mode")
}

func getLastSplitElement(value string, sep string) string {
	splitted := strings.Split(value, sep)
	return splitted[len(splitted)-1]
}

// getResultFieldStrSlice parses a field of a results list into a string slice
func getResultFieldStrSlice(rs []gjson.Result, field string) []string {
	s := make([]string, 0)
	for _, r := range rs {
		s = append(s, r.Get(field).String())
	}
	return s
}

func TestOrg(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	terraformSA := bootstrap.GetStringOutput("organization_step_terraform_service_account_email")
	networksTerraformSA := bootstrap.GetStringOutput("networks_step_terraform_service_account_email")

	vars := map[string]interface{}{
		"terraform_service_account":               terraformSA,
		"networks_step_terraform_service_account_email": networksTerraformSA,
	}

	org := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../1-org/envs/shared"),
		tft.WithVars(vars),
	)

	org.DefineVerify(
		func(assert *assert.Assertions) {
			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			org.DefaultVerify(assert)

			parentFolder := getLastSplitElement(org.GetStringOutput("parent_resource_id"), "/")

			// creation of common folder
			commonFolder := getLastSplitElement(org.GetStringOutput("common_folder_name"), "/")
			folder := gcloud.Runf(t, "resource-manager folders describe %s", commonFolder)
			assert.Equal("fldr-common", folder.Get("displayName").String(), "folder fldr-common should have been created")

			// boolean organization policies
			for _, booleanConstraint := range []string{
				"constraints/compute.disableNestedVirtualization",
				"constraints/compute.disableSerialPortAccess",
				"constraints/compute.disableGuestAttributesAccess",
				"constraints/compute.skipDefaultNetworkCreation",
				"constraints/compute.restrictXpnProjectLienRemoval",
				"constraints/sql.restrictPublicIp",
				"constraints/iam.disableServiceAccountKeyCreation",
				"constraints/storage.uniformBucketLevelAccess",
				"constraints/iam.automaticIamGrantsForDefaultServiceAccounts",
			} {
				orgPolicy := gcloud.Runf(t, "resource-manager org-policies describe %s --folder %s", booleanConstraint, parentFolder)
				assert.True(orgPolicy.Get("booleanPolicy.enforced").Bool(), fmt.Sprintf("org policy %s should be enforced", booleanConstraint))
			}

			// list policies
			restrictedDomain := gcloud.Runf(t, "resource-manager org-policies describe %s --folder %s", "constraints/iam.allowedPolicyMemberDomains", parentFolder)
			assert.Equal(1, len(restrictedDomain.Get("listPolicy.allowedValues").Array()), "restricted domain org policy should be enforced")

			vmExternalIpAccess := gcloud.Runf(t, "resource-manager org-policies describe %s --folder %s", "constraints/compute.vmExternalIpAccess", parentFolder)
			assert.Equal("DENY", vmExternalIpAccess.Get("listPolicy.allValues").String(), "org policy should deny all external IP access")

			// compute.requireOsLogin is neither a boolean policy nor a list policy
			requireOsLogin := gcloud.Runf(t, "resource-manager org-policies describe %s --folder %s", "constraints/compute.requireOsLogin", parentFolder)
			assert.Equal("constraints/compute.requireOsLogin", requireOsLogin.Get("constraint").String(), "org policy should require OS Login")

			// security command center
			sccProjectID := org.GetStringOutput("scc_notifications_project_id")
			topicName := "top-scc-notification"
			topicFullName := fmt.Sprintf("projects/%s/topics/%s", sccProjectID, topicName)
			topic := gcloud.Runf(t, "pubsub topics describe %s --project %s", topicName, sccProjectID)
			assert.Equal(topicFullName, topic.Get("name").String(), fmt.Sprintf("topic %s should have been created", topicName))

			subscriptionName := "sub-scc-notification"
			subscriptionFullName := fmt.Sprintf("projects/%s/subscriptions/%s", sccProjectID, subscriptionName)
			subscription := gcloud.Runf(t, "pubsub subscriptions describe %s --project %s", subscriptionName, sccProjectID)
			assert.Equal(subscriptionFullName, subscription.Get("name").String(), fmt.Sprintf("subscription %s should have been created", subscriptionName))

			orgID := utils.ValFromEnv(t, "TF_VAR_org_id")
			notificationName := org.GetStringOutput("scc_notification_name")
			notification := gcloud.Runf(t, "scc notifications describe %s --organization %s", notificationName, orgID)
			assert.Equal(topicFullName, notification.Get("pubsubTopic").String(), fmt.Sprintf("notification %s should use topic %s", notificationName, topicName))

			//logging
			billingLogsProjectID := org.GetStringOutput("org_billing_logs_project_id")
			billingDatasetName := "billing_data"
			billingDatasetFullName := fmt.Sprintf("%s:%s", billingLogsProjectID, billingDatasetName)
			billingDataset := gcloud.Runf(t, "alpha bq datasets describe %s --project %s", billingDatasetName, billingLogsProjectID)
			assert.Equal(billingDatasetFullName, billingDataset.Get("id").String(), fmt.Sprintf("dataset %s should exist", billingDatasetFullName))

			auditLogsProjectID := org.GetStringOutput("org_audit_logs_project_id")

			auditLogsDatasetName := "audit_logs"
			auditLogsDatasetFullName := fmt.Sprintf("%s:%s", auditLogsProjectID, auditLogsDatasetName)
			auditLogsDataset := gcloud.Runf(t, "alpha bq datasets describe %s --project %s", auditLogsDatasetName, auditLogsProjectID)
			assert.Equal(auditLogsDatasetFullName, auditLogsDataset.Get("id").String(), fmt.Sprintf("dataset %s should exist", auditLogsDatasetFullName))

			logsExportStorageBucketName := org.GetStringOutput("logs_export_storage_bucket_name")
			gcAlphaOpts := gcloud.WithCommonArgs([]string{"--project", auditLogsProjectID, "--json"})
			bkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", logsExportStorageBucketName), gcAlphaOpts).Array()[0]
			assert.Equal(logsExportStorageBucketName, bkt.Get("metadata.id").String(), fmt.Sprintf("Bucket %s should exist", logsExportStorageBucketName))

			logsExportTopicName := org.GetStringOutput("logs_export_pubsub_topic")
			logsExportTopicFullName := fmt.Sprintf("projects/%s/topics/%s", auditLogsProjectID, logsExportTopicName)
			logsExportTopic := gcloud.Runf(t, "pubsub topics describe %s --project %s", logsExportTopicName, auditLogsProjectID)
			assert.Equal(logsExportTopicFullName, logsExportTopic.Get("name").String(), fmt.Sprintf("topic %s should have been created", logsExportTopicName))

			// logging sinks
			mainLogsFilter := []string{
				"logName: /logs/cloudaudit.googleapis.com%2Factivity",
				"logName: /logs/cloudaudit.googleapis.com%2Fsystem_event",
				"logName: /logs/cloudaudit.googleapis.com%2Fdata_access",
				"logName: /logs/compute.googleapis.com%2Fvpc_flows",
				"logName: /logs/compute.googleapis.com%2Ffirewall",
				"logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency",
			}

			for _, sink := range []struct {
				name        string
				hasFilter   bool
				destination string
			}{
				{
					name:        "sk-c-logging-bkt",
					hasFilter:   false,
					destination: fmt.Sprintf("storage.googleapis.com/%s", logsExportStorageBucketName),
				},
				{
					name:        "sk-c-logging-pub",
					hasFilter:   true,
					destination: fmt.Sprintf("pubsub.googleapis.com/projects/%s/topics/%s", auditLogsProjectID, logsExportTopicName),
				},
				{
					name:        "sk-c-logging-bq",
					hasFilter:   true,
					destination: fmt.Sprintf("bigquery.googleapis.com/projects/%s/datasets/%s", auditLogsProjectID, auditLogsDatasetName),
				},
			} {
				logSink := gcloud.Runf(t, "logging sinks describe %s --folder %s", sink.name, parentFolder)
				assert.True(logSink.Get("includeChildren").Bool(), fmt.Sprintf("sink %s should include children", sink.name))
				assert.Equal(sink.destination, logSink.Get("destination").String(), fmt.Sprintf("sink %s should have destination %s", sink.name, sink.destination))
				if sink.hasFilter {
					for _, filter := range mainLogsFilter {
						assert.Contains(logSink.Get("filter").String(), filter, fmt.Sprintf("sink %s should include filter %s", sink.name, filter))
					}
				} else {
					assert.Equal("", logSink.Get("filter").String(), fmt.Sprintf("sink %s should not have a filter", sink.name))
				}
			}

			// hub and spoke infrastructure
			if isHubAndSpoke(t) {
				for _, hubAndSpokeProjectOutput := range []string{
					"base_net_hub_project_id",
					"restricted_net_hub_project_id",
				} {
					projectID := org.GetStringOutput(hubAndSpokeProjectOutput)
					gcOps := gcloud.WithCommonArgs([]string{"--filter", fmt.Sprintf("projectId:%s", projectID), "--format", "json"})
					projects := gcloud.Run(t, "projects list", gcOps).Array()
					assert.Equal(1, len(projects), fmt.Sprintf("project %s should exist", projectID))
					assert.Equal("ACTIVE", projects[0].Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))
				}
			}

			//projects creation
			for _, projectOutput := range []struct {
				output string
				apis   []string
			}{
				{
					output: "org_audit_logs_project_id",
					apis: []string{
						"logging.googleapis.com",
						"bigquery.googleapis.com",
					},
				},
				{
					output: "org_billing_logs_project_id",
					apis: []string{
						"logging.googleapis.com",
						"bigquery.googleapis.com",
						"billingbudgets.googleapis.com",
					},
				},
				{
					output: "org_secrets_project_id",
					apis: []string{
						"logging.googleapis.com",
						"secretmanager.googleapis.com",
					},
				},
				{
					output: "interconnect_project_id",
					apis: []string{
						"billingbudgets.googleapis.com",
						"compute.googleapis.com",
					},
				},
				{
					output: "scc_notifications_project_id",
					apis: []string{
						"logging.googleapis.com",
						"pubsub.googleapis.com",
						"securitycenter.googleapis.com",
					},
				},
				{
					output: "dns_hub_project_id",
					apis: []string{
						"compute.googleapis.com",
						"dns.googleapis.com",
						"servicenetworking.googleapis.com",
						"logging.googleapis.com",
						"cloudresourcemanager.googleapis.com",
					},
				},
			} {
				projectID := org.GetStringOutput(projectOutput.output)
				prj := gcloud.Runf(t, "projects describe %s", projectID)
				assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))

				enabledAPIS := gcloud.Runf(t, "services list --project %s", projectID).Array()
				listApis := getResultFieldStrSlice(enabledAPIS, "config.name")
				assert.Subset(listApis, projectOutput.apis, "APIs should have been enabled")
			}
		})
	org.Test()
}
