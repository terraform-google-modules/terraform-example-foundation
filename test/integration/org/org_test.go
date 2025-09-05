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
	"strconv"
	"strings"
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

func TestOrg(t *testing.T) {

	bootstrap := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../0-bootstrap"),
	)

	backend_bucket := bootstrap.GetStringOutput("gcs_bucket_tfstate")

	ingressPolicies := []map[string]interface{}{}

	egressPolicies := []map[string]interface{}{}

	terraformSA := bootstrap.GetStringOutput("organization_step_terraform_service_account_email")

	// Create Access Context Manager Policy ID if needed
	orgID := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")["org_id"]
	policyID := testutils.GetOrgACMPolicyID(t, orgID)

	if policyID == "" {
		_, err := gcloud.RunCmdE(t, fmt.Sprintf("access-context-manager policies create --organization %s --title %s --impersonate-service-account %s", orgID, "defaultpolicy", terraformSA))
		// ignore creation error and proceed with the test
		if err != nil {
			fmt.Printf("Ignore error in creation of access-context-manager policy ID for organization %s. Error: [%s]", orgID, err.Error())
		}
	}

	vars := map[string]interface{}{
		"remote_state_bucket":              backend_bucket,
		"log_export_storage_force_destroy": "true",
		"folder_deletion_protection":       false,
		"project_deletion_policy":          "DELETE",
		"access_context_manager_policy_id": policyID,
		"ingress_policies":                 ingressPolicies,
		"egress_policies":                  egressPolicies,
		"perimeter_additional_members":     []string{},
	}

	restrictedServices := []string{
		"serviceusage.googleapis.com",
		"essentialcontacts.googleapis.com",
		"accessapproval.googleapis.com",
		"adsdatahub.googleapis.com",
		"aiplatform.googleapis.com",
		"alloydb.googleapis.com",
		"alpha-documentai.googleapis.com",
		"analyticshub.googleapis.com",
		"apigee.googleapis.com",
		"apigeeconnect.googleapis.com",
		"artifactregistry.googleapis.com",
		"assuredworkloads.googleapis.com",
		"automl.googleapis.com",
		"baremetalsolution.googleapis.com",
		"batch.googleapis.com",
		"bigquery.googleapis.com",
		"bigquerydatapolicy.googleapis.com",
		"bigquerydatatransfer.googleapis.com",
		"bigquerymigration.googleapis.com",
		"bigqueryreservation.googleapis.com",
		"bigtable.googleapis.com",
		"binaryauthorization.googleapis.com",
		"cloud.googleapis.com",
		"cloudasset.googleapis.com",
		"cloudbuild.googleapis.com",
		"clouddebugger.googleapis.com",
		"clouddeploy.googleapis.com",
		"clouderrorreporting.googleapis.com",
		"cloudfunctions.googleapis.com",
		"cloudkms.googleapis.com",
		"cloudprofiler.googleapis.com",
		"cloudresourcemanager.googleapis.com",
		"cloudscheduler.googleapis.com",
		"cloudsearch.googleapis.com",
		"cloudtrace.googleapis.com",
		"composer.googleapis.com",
		"compute.googleapis.com",
		"connectgateway.googleapis.com",
		"contactcenterinsights.googleapis.com",
		"container.googleapis.com",
		"containeranalysis.googleapis.com",
		"containerfilesystem.googleapis.com",
		"containerregistry.googleapis.com",
		"containerthreatdetection.googleapis.com",
		"datacatalog.googleapis.com",
		"dataflow.googleapis.com",
		"datafusion.googleapis.com",
		"datamigration.googleapis.com",
		"dataplex.googleapis.com",
		"dataproc.googleapis.com",
		"datastream.googleapis.com",
		"dialogflow.googleapis.com",
		"dlp.googleapis.com",
		"dns.googleapis.com",
		"documentai.googleapis.com",
		"domains.googleapis.com",
		"eventarc.googleapis.com",
		"file.googleapis.com",
		"firebaseappcheck.googleapis.com",
		"firebaserules.googleapis.com",
		"firestore.googleapis.com",
		"gameservices.googleapis.com",
		"gkebackup.googleapis.com",
		"gkeconnect.googleapis.com",
		"gkehub.googleapis.com",
		"healthcare.googleapis.com",
		"iam.googleapis.com",
		"iamcredentials.googleapis.com",
		"iaptunnel.googleapis.com",
		"ids.googleapis.com",
		"integrations.googleapis.com",
		"kmsinventory.googleapis.com",
		"krmapihosting.googleapis.com",
		"language.googleapis.com",
		"lifesciences.googleapis.com",
		"logging.googleapis.com",
		"managedidentities.googleapis.com",
		"memcache.googleapis.com",
		"meshca.googleapis.com",
		"meshconfig.googleapis.com",
		"metastore.googleapis.com",
		"ml.googleapis.com",
		"monitoring.googleapis.com",
		"networkconnectivity.googleapis.com",
		"networkmanagement.googleapis.com",
		"networksecurity.googleapis.com",
		"networkservices.googleapis.com",
		"notebooks.googleapis.com",
		"opsconfigmonitoring.googleapis.com",
		"orgpolicy.googleapis.com",
		"osconfig.googleapis.com",
		"oslogin.googleapis.com",
		"privateca.googleapis.com",
		"pubsub.googleapis.com",
		"pubsublite.googleapis.com",
		"recaptchaenterprise.googleapis.com",
		"recommender.googleapis.com",
		"redis.googleapis.com",
		"retail.googleapis.com",
		"run.googleapis.com",
		"secretmanager.googleapis.com",
		"servicecontrol.googleapis.com",
		"servicedirectory.googleapis.com",
		"spanner.googleapis.com",
		"speakerid.googleapis.com",
		"speech.googleapis.com",
		"sqladmin.googleapis.com",
		"storage.googleapis.com",
		"storagetransfer.googleapis.com",
		"sts.googleapis.com",
		"texttospeech.googleapis.com",
		"timeseriesinsights.googleapis.com",
		"tpu.googleapis.com",
		"trafficdirector.googleapis.com",
		"transcoder.googleapis.com",
		"translate.googleapis.com",
		"videointelligence.googleapis.com",
		"vision.googleapis.com",
		"visionai.googleapis.com",
		"vmmigration.googleapis.com",
		"vpcaccess.googleapis.com",
		"webrisk.googleapis.com",
		"workflows.googleapis.com",
		"workstations.googleapis.com",
	}

	backendConfig := map[string]interface{}{
		"bucket": backend_bucket,
	}

	// Configure impersonation for test execution
	utils.SetEnv(t, "GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", terraformSA)

	org := tft.NewTFBlueprintTest(t,
		tft.WithTFDir("../../../1-org/envs/shared"),
		tft.WithVars(vars),
		tft.WithRetryableTerraformErrors(testutils.RetryableTransientErrors, 1, 2*time.Minute),
		tft.WithPolicyLibraryPath("/workspace/policy-library", bootstrap.GetTFSetupStringOutput("project_id")),
		tft.WithBackendConfig(backendConfig),
	)

	org.DefineApply(
		func(assert *assert.Assertions) {
			projectID := bootstrap.GetStringOutput("seed_project_id")
			for _, api := range []string{
				"serviceusage.googleapis.com",
				"servicenetworking.googleapis.com",
				"cloudkms.googleapis.com",
				"compute.googleapis.com",
				"logging.googleapis.com",
				"bigquery.googleapis.com",
				"cloudresourcemanager.googleapis.com",
				"cloudbilling.googleapis.com",
				"cloudbuild.googleapis.com",
				"iam.googleapis.com",
				"admin.googleapis.com",
				"appengine.googleapis.com",
				"storage-api.googleapis.com",
				"monitoring.googleapis.com",
				"pubsub.googleapis.com",
				"securitycenter.googleapis.com",
				"accesscontextmanager.googleapis.com",
				"billingbudgets.googleapis.com",
				"essentialcontacts.googleapis.com",
			} {
				utils.Poll(t, func() (bool, error) { return testutils.CheckAPIEnabled(t, projectID, api) }, 5, 2*time.Minute)
			}

			org.DefaultApply(assert)
		})
	org.DefineVerify(
		func(assert *assert.Assertions) {
			// perform default verification ensuring Terraform reports no additional changes on an applied blueprint
			org.DefaultVerify(assert)

			parentFolder := testutils.GetLastSplitElement(org.GetStringOutput("parent_resource_id"), "/")

			// creation of common folder
			commonFolder := testutils.GetLastSplitElement(org.GetStringOutput("common_folder_name"), "/")
			folder := gcloud.Runf(t, "resource-manager folders describe %s", commonFolder)
			assert.Equal("fldr-common", folder.Get("displayName").String(), "folder fldr-common should have been created")

			// creation of network folder
			networkFolder := testutils.GetLastSplitElement(org.GetStringOutput("network_folder_name"), "/")
			folderOP := gcloud.Runf(t, "resource-manager folders describe %s", networkFolder)
			assert.Equal("fldr-network", folderOP.Get("displayName").String(), "folder fldr-network should have been created")

			// check tags applied to common and bootstrap folder
			commonConfig := terraform.OutputMap(t, bootstrap.GetTFOptions(), "common_config")
			bootstrapFolder := testutils.GetLastSplitElement(commonConfig["bootstrap_folder_name"], "/")

			servicePerimeterLink := fmt.Sprintf("accessPolicies/%s/servicePerimeters/%s", policyID, org.GetStringOutput("service_perimeter_name"))
			accessLevel := fmt.Sprintf("accessPolicies/%s/accessLevels/%s", policyID, org.GetStringOutput("access_level_name_dry_run"))
			servicePerimeter, err := gcloud.RunCmdE(t, fmt.Sprintf("access-context-manager perimeters dry-run describe %s --policy %s --format=json", servicePerimeterLink, policyID))
			assert.NoError(err)
			perimeterName := org.GetStringOutput("service_perimeter_name")
			assert.True(strings.Contains(servicePerimeter, perimeterName), fmt.Sprintf("service perimeter %s should exist", perimeterName))
			assert.True(strings.Contains(servicePerimeter, accessLevel), fmt.Sprintf("service perimeter %s should have access level %s", servicePerimeterLink, accessLevel))
			for _, service := range restrictedServices {
				assert.True(strings.Contains(servicePerimeter, service), fmt.Sprintf("service perimeter %s should restrict all supported services", servicePerimeterLink))
			}
			for _, tags := range []struct {
				folderId   string
				folderName string
				value      string
			}{
				{
					folderId:   commonFolder,
					folderName: "common",
					value:      "production",
				},
				{
					folderId:   networkFolder,
					folderName: "network",
					value:      "production",
				},
				{
					folderId:   bootstrapFolder,
					folderName: "bootstrap",
					value:      "bootstrap",
				},
			} {
				fldrTags := gcloud.Runf(t, "resource-manager tags bindings list --parent=//cloudresourcemanager.googleapis.com/folders/%s", tags.folderId).Array()
				fldrsTagValuesId := testutils.GetResultFieldStrSlice(fldrTags, "tagValue")

				var fldrsTagValues []string
				for _, tagValueId := range fldrsTagValuesId {
					tagValueObj := gcloud.Runf(t, "resource-manager tags values describe %s", tagValueId)
					fldrsTagValues = append(fldrsTagValues, tagValueObj.Get("shortName").String())
				}

				assert.Contains(fldrsTagValues, tags.value, fmt.Sprintf("folder %s (%s) should have tag %s", tags.folderName, tags.folderId, tags.value))
			}

			// boolean organization policies
			for _, booleanConstraint := range []string{
				"constraints/compute.disableNestedVirtualization",
				"constraints/compute.disableSerialPortAccess",
				"constraints/compute.skipDefaultNetworkCreation",
				"constraints/compute.restrictXpnProjectLienRemoval",
				"constraints/sql.restrictPublicIp",
				"constraints/sql.restrictAuthorizedNetworks",
				"constraints/iam.disableServiceAccountKeyCreation",
				"constraints/storage.uniformBucketLevelAccess",
				"constraints/storage.publicAccessPrevention",
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

			// security command center (commented out with issue #1189)
			// sccProjectID := org.GetStringOutput("scc_notifications_project_id")
			// topicName := "top-scc-notification"
			// topicFullName := fmt.Sprintf("projects/%s/topics/%s", sccProjectID, topicName)
			// topic := gcloud.Runf(t, "pubsub topics describe %s --project %s", topicName, sccProjectID)
			// assert.Equal(topicFullName, topic.Get("name").String(), fmt.Sprintf("topic %s should have been created", topicName))

			// subscriptionName := "sub-scc-notification"
			// subscriptionFullName := fmt.Sprintf("projects/%s/subscriptions/%s", sccProjectID, subscriptionName)
			// subscription := gcloud.Runf(t, "pubsub subscriptions describe %s --project %s", subscriptionName, sccProjectID)
			// assert.Equal(subscriptionFullName, subscription.Get("name").String(), fmt.Sprintf("subscription %s should have been created", subscriptionName))

			// orgID := bootstrap.GetTFSetupStringOutput("org_id")
			// notificationName := org.GetStringOutput("scc_notification_name")
			// notification := gcloud.Runf(t, "scc notifications describe %s --organization %s", notificationName, orgID)
			// assert.Equal(topicFullName, notification.Get("pubsubTopic").String(), fmt.Sprintf("notification %s should use topic %s", notificationName, topicName))

			//essential contacts
			//test case considers that just the Org Admin group exists and will subscribe for all categories
			essentialContacts := gcloud.Runf(t, "essential-contacts list --folder=%s", parentFolder).Array()
			assert.Len(essentialContacts, 1, "only one essential contact email should be created")

			groupOrgAdmins := utils.ValFromEnv(t, "TF_VAR_group_email")
			assert.Equal(groupOrgAdmins, essentialContacts[0].Get("email").String(), "essential contact email should be group org admin")
			assert.Equal("VALID", essentialContacts[0].Get("validationState").String(), "state of essential contact should be valid")

			listCategories := utils.GetResultStrSlice(essentialContacts[0].Get("notificationCategorySubscriptions").Array())
			expectedCategories := []string{"BILLING", "LEGAL", "PRODUCT_UPDATES", "SECURITY", "SUSPENSION", "TECHNICAL"}
			assert.Subset(listCategories, expectedCategories, "notification category subscriptions should be the same")

			//logging
			billingLogsProjectID := org.GetStringOutput("org_billing_export_project_id")
			billingDatasetName := "billing_data"
			billingDatasetFullName := fmt.Sprintf("%s:%s", billingLogsProjectID, billingDatasetName)
			billingDataset := gcloud.Runf(t, "alpha bq datasets describe %s --project %s", billingDatasetName, billingLogsProjectID)
			assert.Equal(billingDatasetFullName, billingDataset.Get("id").String(), fmt.Sprintf("dataset %s should exist", billingDatasetFullName))

			auditLogsProjectID := org.GetStringOutput("org_audit_logs_project_id")

			// Bucket destination
			logsExportStorageBucketName := org.GetStringOutput("logs_export_storage_bucket_name")
			gcAlphaOpts := gcloud.WithCommonArgs([]string{"--project", auditLogsProjectID, "--json"})
			bkt := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", logsExportStorageBucketName), gcAlphaOpts).Array()[0]
			assert.Equal(logsExportStorageBucketName, bkt.Get("metadata.id").String(), fmt.Sprintf("Bucket %s should exist", logsExportStorageBucketName))

			// Pub/Sub destination
			logsExportTopicName := org.GetStringOutput("logs_export_pubsub_topic")
			logsExportTopicFullName := fmt.Sprintf("projects/%s/topics/%s", auditLogsProjectID, logsExportTopicName)
			logsExportTopic := gcloud.Runf(t, "pubsub topics describe %s --project %s", logsExportTopicName, auditLogsProjectID)
			assert.Equal(logsExportTopicFullName, logsExportTopic.Get("name").String(), fmt.Sprintf("topic %s should have been created", logsExportTopicName))

			// Project destination
			prjLogsExportLogBktName := org.GetStringOutput("logs_export_project_logbucket_name")
			defaultRegion := commonConfig["default_region"]
			prjLogBktFullName := fmt.Sprintf("projects/%s/locations/%s/buckets/%s", auditLogsProjectID, defaultRegion, prjLogsExportLogBktName)
			prjLogBktDetails := gcloud.Runf(t, fmt.Sprintf("logging buckets describe %s --location=%s --project=%s", prjLogsExportLogBktName, defaultRegion, auditLogsProjectID))
			assert.Equal(prjLogBktFullName, prjLogBktDetails.Get("name").String(), "log bucket name should match")

			prjLinkedDatasetID := "ds_c_prj_aggregated_logs_analytics"
			prjLinkedDsName := org.GetStringOutput("logs_export_project_linked_dataset_name")
			prjLinkedDs := gcloud.Runf(t, "logging links describe %s --bucket=%s --location=%s --project=%s", prjLinkedDatasetID, prjLogsExportLogBktName, defaultRegion, auditLogsProjectID)
			assert.Equal(prjLinkedDsName, prjLinkedDs.Get("name").String(), "log bucket linked dataset name should match")
			prjBigqueryDatasetID := fmt.Sprintf("bigquery.googleapis.com/projects/%s/datasets/%s", auditLogsProjectID, prjLinkedDatasetID)
			assert.Equal(prjBigqueryDatasetID, prjLinkedDs.Get("bigqueryDataset.datasetId").String(), "log bucket BigQuery dataset ID should match")

			// add filter exclusion
			prjLogsExportDefaultSink := gcloud.Runf(t, "logging sinks describe _Default --project=%s", auditLogsProjectID)
			exclusions := prjLogsExportDefaultSink.Get("exclusions").Array()
			assert.NotEmpty(exclusions, fmt.Sprintf("exclusion list for _Default sink in project %s must not be empty", auditLogsProjectID))
			exclusionFilter := fmt.Sprintf("-logName : \"/%s/\"", auditLogsProjectID)
			assert.Equal(exclusions[0].Get("filter").String(), exclusionFilter)

			// logging sinks
			logsFilter := []string{
				"logName: /logs/cloudaudit.googleapis.com%2Factivity",
				"logName: /logs/cloudaudit.googleapis.com%2Fsystem_event",
				"logName: /logs/cloudaudit.googleapis.com%2Fdata_access",
				"logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency",
				"logName: /logs/cloudaudit.googleapis.com%2Fpolicy",
				"logName: /logs/compute.googleapis.com%2Fvpc_flows",
				"logName: /logs/compute.googleapis.com%2Ffirewall",
				"logName: /logs/dns.googleapis.com%2Fdns_queries",
			}

			// Log Sink
			for _, sink := range []struct {
				name        string
				destination string
			}{
				{
					name:        "sk-c-logging-bkt",
					destination: fmt.Sprintf("storage.googleapis.com/%s", logsExportStorageBucketName),
				},
				{
					name:        "sk-c-logging-pub",
					destination: fmt.Sprintf("pubsub.googleapis.com/projects/%s/topics/%s", auditLogsProjectID, logsExportTopicName),
				},
				{
					name:        "sk-c-logging-prj",
					destination: fmt.Sprintf("logging.googleapis.com/projects/%s", auditLogsProjectID),
				},
			} {
				logSink := gcloud.Runf(t, "logging sinks describe %s --folder %s", sink.name, parentFolder)
				assert.True(logSink.Get("includeChildren").Bool(), fmt.Sprintf("sink %s should include children", sink.name))
				assert.Equal(sink.destination, logSink.Get("destination").String(), fmt.Sprintf("sink %s should have destination %s", sink.name, sink.destination))
				for _, filter := range logsFilter {
					assert.Contains(logSink.Get("filter").String(), filter, fmt.Sprintf("sink %s should include filter %s", sink.name, filter))
				}
			}

			// CAI Monitoring (commented out with issue #1189)
			// Variables
			// caiAr := org.GetStringOutput("cai_monitoring_artifact_registry")
			// caiBucket := org.GetStringOutput("cai_monitoring_bucket")
			// caiTopic := org.GetStringOutput("cai_monitoring_topic")

			// caiSaEmail := fmt.Sprintf("cai-monitoring@%s.iam.gserviceaccount.com", sccProjectID)
			// caiTopicFullName := fmt.Sprintf("projects/%s/topics/%s", sccProjectID, caiTopic)

			// Cloud Function
			// opCf := gcloud.Runf(t, "functions describe caiMonitoring --project %s --gen2 --region %s", sccProjectID, defaultRegion)
			// assert.Equal("ACTIVE", opCf.Get("state").String(), "Should be ACTIVE. Cloud Function is not successfully deployed.")
			// assert.Equal(caiSaEmail, opCf.Get("serviceConfig.serviceAccountEmail").String(), fmt.Sprintf("Cloud Function should use the service account %s.", caiSaEmail))
			// assert.Contains(opCf.Get("eventTrigger.eventType").String(), "google.cloud.pubsub.topic.v1.messagePublished", "Event Trigger is not based on Pub/Sub message. Check the EventType configuration.")

			// Cloud Function Storage Bucket
			// bktArgs := gcloud.WithCommonArgs([]string{"--project", sccProjectID, "--json"})
			// opSrcBucket := gcloud.Run(t, fmt.Sprintf("alpha storage ls --buckets gs://%s", caiBucket), bktArgs).Array()
			// assert.Equal("true", opSrcBucket[0].Get("metadata.iamConfiguration.bucketPolicyOnly.enabled").String(), "Should have Bucket Policy Only enabled.")

			// Cloud Function Artifact Registry
			// opAR := gcloud.Runf(t, "artifacts repositories describe %s --project %s --location %s", caiAr, sccProjectID, defaultRegion)
			// assert.Equal("DOCKER", opAR.Get("format").String(), "Should have type: DOCKER")

			// Cloud Function Pub/Sub
			// opTopic := gcloud.Runf(t, "pubsub topics describe %s --project %s", caiTopic, sccProjectID)
			// assert.Equal(caiTopicFullName, opTopic.Get("name").String(), fmt.Sprintf("Topic %s should have been created", caiTopicFullName))

			// Log Sink
			for _, sink := range []struct {
				name        string
				destination string
			}{
				{
					name:        "sk-c-logging-bkt",
					destination: fmt.Sprintf("storage.googleapis.com/%s", logsExportStorageBucketName),
				},
				{
					name:        "sk-c-logging-prj",
					destination: fmt.Sprintf("logging.googleapis.com/projects/%s", auditLogsProjectID),
				},
				{
					name:        "sk-c-logging-pub",
					destination: fmt.Sprintf("pubsub.googleapis.com/projects/%s/topics/%s", auditLogsProjectID, logsExportTopicName),
				},
			} {
				logSink := gcloud.Runf(t, "logging sinks describe %s --folder %s", sink.name, parentFolder)
				assert.True(logSink.Get("includeChildren").Bool(), fmt.Sprintf("sink %s should include children", sink.name))
				assert.Equal(sink.destination, logSink.Get("destination").String(), fmt.Sprintf("sink %s should have destination %s", sink.name, sink.destination))
				for _, filter := range logsFilter {
					assert.Contains(logSink.Get("filter").String(), filter, fmt.Sprintf("sink %s should include filter %s", sink.name, filter))
				}

			}

			// Log Sink billing
			billingAccount := org.GetTFSetupStringOutput("billing_account")
			billingSinkNames := terraform.OutputMap(t, org.GetTFOptions(), "billing_sink_names")
			billingPRJSinkName := billingSinkNames["prj"]
			billingPUBSinkName := billingSinkNames["pub"]
			billingSTOSinkName := billingSinkNames["sto"]

			for _, sinkBilling := range []struct {
				name        string
				destination string
			}{
				{
					name:        billingSTOSinkName,
					destination: fmt.Sprintf("storage.googleapis.com/%s", logsExportStorageBucketName),
				},
				{
					name:        billingPRJSinkName,
					destination: fmt.Sprintf("logging.googleapis.com/projects/%s", auditLogsProjectID),
				},
				{
					name:        billingPUBSinkName,
					destination: fmt.Sprintf("pubsub.googleapis.com/projects/%s/topics/%s", auditLogsProjectID, logsExportTopicName),
				},
			} {
				logSinkBilling := gcloud.Runf(t, "logging sinks describe %s --billing-account %s", sinkBilling.name, billingAccount)
				assert.Equal(sinkBilling.destination, logSinkBilling.Get("destination").String(), fmt.Sprintf("sink %s should have destination %s", sinkBilling.name, sinkBilling.destination))
			}

			// verify seed project in perimeter
			sharedProjectNumber := bootstrap.GetStringOutput("seed_project_number")
			perimeter := gcloud.Runf(t, "access-context-manager perimeters dry-run describe %s --policy %s --format=json", servicePerimeterLink, policyID)
			projectFormat := fmt.Sprintf("projects/%s", sharedProjectNumber)
			perimeterResources := utils.GetResultStrSlice(perimeter.Get("spec.resources").Array())
			assert.Contains(perimeterResources, projectFormat, fmt.Sprintf("dry-run service perimeter %s should contain %s", perimeterName, projectFormat))

			// hub and spoke infrastructure
			enable_hub_and_spoke, err := strconv.ParseBool(bootstrap.GetTFSetupStringOutput("enable_hub_and_spoke"))
			require.NoError(t, err)
			if enable_hub_and_spoke {
				for _, hubAndSpokeProjectOutput := range []string{
					"net_hub_project_id",
				} {
					projectID := org.GetStringOutput(hubAndSpokeProjectOutput)
					gcOps := gcloud.WithCommonArgs([]string{"--filter", fmt.Sprintf("projectId:%s", projectID), "--format", "json"})
					projects := gcloud.Run(t, "projects list", gcOps).Array()
					assert.Equal(1, len(projects), fmt.Sprintf("project %s should exist", projectID))
					assert.Equal("ACTIVE", projects[0].Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))
					numberOutput := strings.ReplaceAll(hubAndSpokeProjectOutput, "_id", "_number") // "net_hub_project_number"
					projectNumber := org.GetStringOutput(numberOutput)
					perimeter := gcloud.Runf(t, "access-context-manager perimeters dry-run describe %s --policy %s --format=json", servicePerimeterLink, policyID)
					projectFormat := fmt.Sprintf("projects/%s", projectNumber)
					perimeterResources := utils.GetResultStrSlice(perimeter.Get("spec.resources").Array())
					assert.Contains(perimeterResources, projectFormat, fmt.Sprintf("dry-run service perimeter %s should contain %s", perimeterName, projectFormat))
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
					output: "org_billing_export_project_id",
					apis: []string{
						"logging.googleapis.com",
						"bigquery.googleapis.com",
						"billingbudgets.googleapis.com",
					},
				},
				{
					output: "common_kms_project_id",
					apis: []string{
						"logging.googleapis.com",
						"cloudkms.googleapis.com",
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
			} {
				projectID := org.GetStringOutput(projectOutput.output)
				prj := gcloud.Runf(t, "projects describe %s", projectID)
				assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))
				projectNumber := prj.Get("projectNumber").String()
				perimeter, err := gcloud.RunCmdE(t, fmt.Sprintf("access-context-manager perimeters dry-run describe %s --policy %s", servicePerimeterLink, policyID))
				assert.NoError(err)
				assert.True(strings.Contains(perimeter, projectNumber), fmt.Sprintf("dry-run service perimeter %s should contain project %s (number: %s)", perimeterName, projectID, projectNumber))
				enabledAPIS := gcloud.Runf(t, "services list --project %s", projectID).Array()
				listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
				assert.Subset(listApis, projectOutput.apis, "APIs should have been enabled")
			}
			// shared vpc projects
			for _, envName := range []string{
				"development",
				"nonproduction",
				"production",
			} {
				for _, projectEnvOutput := range []struct {
					projectOutput string
					apis          []string
				}{
					{
						projectOutput: "shared_vpc_project_id",
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
				} {
					envProj := terraform.OutputMapOfObjects(t, org.GetTFOptions(), "shared_vpc_projects")[envName].(map[string]interface{})
					projectID := envProj[projectEnvOutput.projectOutput]
					projectNumber := fmt.Sprint(envProj["shared_vpc_project_number"])
					prj := gcloud.Runf(t, "projects describe %s", projectID)
					assert.Equal(projectID, prj.Get("projectId").String(), fmt.Sprintf("project %s should exist", projectID))
					assert.Equal("ACTIVE", prj.Get("lifecycleState").String(), fmt.Sprintf("project %s should be ACTIVE", projectID))
					perimeter := gcloud.Runf(t, "access-context-manager perimeters dry-run describe %s --policy %s --format=json", servicePerimeterLink, policyID)
					projectFormat := fmt.Sprintf("projects/%s", projectNumber)
					perimeterResources := utils.GetResultStrSlice(perimeter.Get("spec.resources").Array())
					assert.Contains(perimeterResources, projectFormat, fmt.Sprintf("dry-run service perimeter %s should contain %s", perimeterName, projectFormat))
					enabledAPIS := gcloud.Runf(t, "services list --project %s", projectID).Array()
					listApis := testutils.GetResultFieldStrSlice(enabledAPIS, "config.name")
					assert.Subset(listApis, projectEnvOutput.apis, "APIs should have been enabled")
				}
			}
		})
	org.Test()
}
