// Copyright 2023 Google LLC
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

package stages

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/gcp"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/msg"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/steps"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func DeployBootstrapStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, c CommonConf) error {
	bootstrapTfvars := BootstrapTfvars{
		OrgID:                        tfvars.OrgID,
		DefaultRegion:                tfvars.DefaultRegion,
		DefaultRegion2:               tfvars.DefaultRegion2,
		DefaultRegionGCS:             tfvars.DefaultRegionGCS,
		DefaultRegionKMS:             tfvars.DefaultRegionKMS,
		BillingAccount:               tfvars.BillingAccount,
		ParentFolder:                 tfvars.ParentFolder,
		ProjectPrefix:                tfvars.ProjectPrefix,
		FolderPrefix:                 tfvars.FolderPrefix,
		BucketForceDestroy:           tfvars.BucketForceDestroy,
		BucketTfstateKmsForceDestroy: tfvars.BucketTfstateKmsForceDestroy,
		Groups:                       tfvars.Groups,
		InitialGroupConfig:           tfvars.InitialGroupConfig,
	}

	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, BootstrapStep, "terraform.tfvars"), bootstrapTfvars)
	if err != nil {
		return err
	}

	// delete README-Jenkins.md due to private key checker false positive
	jenkinsReadme := filepath.Join(c.FoundationPath, BootstrapStep, "README-Jenkins.md")
	exist, err := utils.FileExists(jenkinsReadme)
	if err != nil {
		return err
	}
	if exist {
		err = os.Remove(jenkinsReadme)
		if err != nil {
			return err
		}
	}

	terraformDir := filepath.Join(c.FoundationPath, BootstrapStep)
	options := &terraform.Options{
		TerraformDir: terraformDir,
		Logger:       c.Logger,
		NoColor:      true,
	}
	// terraform deploy
	err = applyLocal(t, options, "", c.PolicyPath, c.ValidatorProject)
	if err != nil {
		return err
	}

	// read bootstrap outputs
	defaultRegion := terraform.OutputMap(t, options, "common_config")["default_region"]
	cbProjectID := terraform.Output(t, options, "cloudbuild_project_id")
	backendBucket := terraform.Output(t, options, "gcs_bucket_tfstate")
	backendBucketProjects := terraform.Output(t, options, "projects_gcs_bucket_tfstate")

	// replace backend and terraform init migrate
	err = s.RunStep("gcp-bootstrap.migrate-state", func() error {
		options.MigrateState = true
		err = utils.CopyFile(filepath.Join(options.TerraformDir, "backend.tf.example"), filepath.Join(options.TerraformDir, "backend.tf"))
		if err != nil {
			return err
		}
		err = utils.ReplaceStringInFile(filepath.Join(options.TerraformDir, "backend.tf"), "UPDATE_ME", backendBucket)
		if err != nil {
			return err
		}
		_, err := terraform.InitE(t, options)
		return err
	})
	if err != nil {
		return err
	}

	// replace all backend files
	err = s.RunStep("gcp-bootstrap.replace-backend-files", func() error {
		files, err := utils.FindFiles(c.FoundationPath, "backend.tf")
		if err != nil {
			return err
		}
		for _, file := range files {
			err = utils.ReplaceStringInFile(file, "UPDATE_ME", backendBucket)
			if err != nil {
				return err
			}
			err = utils.ReplaceStringInFile(file, "UPDATE_PROJECTS_BACKEND", backendBucketProjects)
			if err != nil {
				return err
			}
		}
		return nil
	})
	if err != nil {
		return err
	}

	msg.PrintBuildMsg(cbProjectID, defaultRegion, c.DisablePrompt)

	// Check if image build was successful.
	err = gcp.NewGCP().WaitBuildSuccess(t, cbProjectID, defaultRegion, "tf-cloudbuilder", "", "Terraform Image builder Build Failed for tf-cloudbuilder repository.", MaxBuildRetries)
	if err != nil {
		return err
	}

	//prepare policies repo
	gcpPoliciesPath := filepath.Join(c.CheckoutPath, PoliciesRepo)
	policiesConf := utils.CloneCSR(t, PoliciesRepo, gcpPoliciesPath, cbProjectID, c.Logger)
	policiesBranch := "main"

	err = s.RunStep("gcp-bootstrap.gcp-policies", func() error {
		return preparePoliciesRepo(policiesConf, policiesBranch, c.FoundationPath, gcpPoliciesPath)
	})
	if err != nil {
		return err
	}

	//prepare bootstrap repo
	gcpBootstrapPath := filepath.Join(c.CheckoutPath, BootstrapRepo)
	bootstrapConf := utils.CloneCSR(t, BootstrapRepo, gcpBootstrapPath, cbProjectID, c.Logger)
	stageConf := StageConf{
		Stage:               BootstrapRepo,
		CICDProject:         cbProjectID,
		DefaultRegion:       defaultRegion,
		Step:                BootstrapStep,
		Repo:                BootstrapRepo,
		CustomTargetDirPath: "envs/shared",
		GitConf:             bootstrapConf,
		Envs:                []string{"shared"},
	}

	// if groups creation is enable the helper will just push the code
	// because Cloud Build build will fail until bootstrap
	// service account is granted Group Admin role in the
	// Google Workspace by a Super Admin.
	// https://github.com/terraform-google-modules/terraform-google-group/blob/main/README.md#google-workspace-formerly-known-as-g-suite-roles
	if tfvars.HasGroupsCreation() {
		err = saveBootstrapCodeOnly(t, stageConf, s, c)
	} else {
		err = deployStage(t, stageConf, s, c)
	}

	if err != nil {
		return err
	}
	// Init gcp-bootstrap terraform
	err = s.RunStep("gcp-bootstrap.init-tf", func() error {
		options := &terraform.Options{
			TerraformDir: filepath.Join(gcpBootstrapPath, "envs", "shared"),
			Logger:       c.Logger,
			NoColor:      true,
		}
		_, err := terraform.InitE(t, options)
		return err
	})
	if err != nil {
		return err
	}
	fmt.Println("end of bootstrap deploy")

	return nil
}

func DeployOrgStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs BootstrapOutputs, c CommonConf) error {

	createACMAPolicy := testutils.GetOrgACMPolicyID(t, tfvars.OrgID) == ""

	orgTfvars := OrgTfvars{
		DomainsToAllow:                        tfvars.DomainsToAllow,
		EssentialContactsDomains:              tfvars.EssentialContactsDomains,
		SccNotificationName:                   tfvars.SccNotificationName,
		RemoteStateBucket:                     outputs.RemoteStateBucket,
		EnableHubAndSpoke:                     tfvars.EnableHubAndSpoke,
		CreateACMAPolicy:                      createACMAPolicy,
		CreateUniqueTagKey:                    tfvars.CreateUniqueTagKey,
		AuditLogsTableDeleteContentsOnDestroy: tfvars.AuditLogsTableDeleteContentsOnDestroy,
		LogExportStorageForceDestroy:          tfvars.LogExportStorageForceDestroy,
		LogExportStorageLocation:              tfvars.LogExportStorageLocation,
		BillingExportDatasetLocation:          tfvars.BillingExportDatasetLocation,
	}
	orgTfvars.GcpGroups = GcpGroups{}
	if tfvars.HasOptionalGroupsCreation() {
		if (*tfvars.Groups.OptionalGroups.GcpSecurityReviewer) != "" {
			orgTfvars.GcpGroups.SecurityReviewer = tfvars.Groups.OptionalGroups.GcpSecurityReviewer
		}
		if (*tfvars.Groups.OptionalGroups.GcpNetworkViewer) != "" {
			orgTfvars.GcpGroups.NetworkViewer = tfvars.Groups.OptionalGroups.GcpNetworkViewer
		}
		if (*tfvars.Groups.OptionalGroups.GcpSccAdmin) != "" {
			orgTfvars.GcpGroups.SccAdmin = tfvars.Groups.OptionalGroups.GcpSccAdmin
		}
		if (*tfvars.Groups.OptionalGroups.GcpGlobalSecretsAdmin) != "" {
			orgTfvars.GcpGroups.GlobalSecretsAdmin = tfvars.Groups.OptionalGroups.GcpGlobalSecretsAdmin
		}
		if (*tfvars.Groups.OptionalGroups.GcpKmsAdmin) != "" {
			orgTfvars.GcpGroups.KmsAdmin = tfvars.Groups.OptionalGroups.GcpKmsAdmin
		}
	}

	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, OrgStep, "envs", "shared", "terraform.tfvars"), orgTfvars)
	if err != nil {
		return err
	}

	conf := utils.CloneCSR(t, OrgRepo, filepath.Join(c.CheckoutPath, OrgRepo), outputs.CICDProject, c.Logger)
	stageConf := StageConf{
		Stage:         OrgRepo,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          OrgStep,
		Repo:          OrgRepo,
		GitConf:       conf,
		Envs:          []string{"shared"},
	}

	return deployStage(t, stageConf, s, c)
}

func DeployEnvStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs BootstrapOutputs, c CommonConf) error {

	envsTfvars := EnvsTfvars{
		RemoteStateBucket: outputs.RemoteStateBucket,
	}
	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, EnvironmentsStep, "terraform.tfvars"), envsTfvars)
	if err != nil {
		return err
	}

	conf := utils.CloneCSR(t, EnvironmentsRepo, filepath.Join(c.CheckoutPath, EnvironmentsRepo), outputs.CICDProject, c.Logger)
	stageConf := StageConf{
		Stage:         EnvironmentsRepo,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          EnvironmentsStep,
		Repo:          EnvironmentsRepo,
		GitConf:       conf,
		Envs:          []string{"production", "nonproduction", "development"},
	}

	return deployStage(t, stageConf, s, c)
}

func DeployNetworksStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs BootstrapOutputs, c CommonConf) error {

	step := GetNetworkStep(c.EnableHubAndSpoke)

	// shared
	sharedTfvars := NetSharedTfvars{
		TargetNameServerAddresses: tfvars.TargetNameServerAddresses,
	}
	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, step, "shared.auto.tfvars"), sharedTfvars)
	if err != nil {
		return err
	}
	// common
	commonTfvars := NetCommonTfvars{
		Domain:                     tfvars.Domain,
		PerimeterAdditionalMembers: tfvars.PerimeterAdditionalMembers,
		RemoteStateBucket:          outputs.RemoteStateBucket,
	}
	if tfvars.EnableHubAndSpoke {
		commonTfvars.EnableHubAndSpokeTransitivity = &tfvars.EnableHubAndSpokeTransitivity
	}
	err = utils.WriteTfvars(filepath.Join(c.FoundationPath, step, "common.auto.tfvars"), commonTfvars)
	if err != nil {
		return err
	}
	//access_context
	accessContextTfvars := NetAccessContextTfvars{
		AccessContextManagerPolicyID: testutils.GetOrgACMPolicyID(t, tfvars.OrgID),
	}
	err = utils.WriteTfvars(filepath.Join(c.FoundationPath, step, "access_context.auto.tfvars"), accessContextTfvars)
	if err != nil {
		return err
	}

	conf := utils.CloneCSR(t, NetworksRepo, filepath.Join(c.CheckoutPath, NetworksRepo), outputs.CICDProject, c.Logger)
	stageConf := StageConf{
		Stage:         NetworksRepo,
		StageSA:       outputs.NetworkSA,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          step,
		Repo:          NetworksRepo,
		GitConf:       conf,
		HasManualStep: true,
		GroupingUnits: []string{"envs"},
		Envs:          []string{"production", "nonproduction", "development"},
	}

	return deployStage(t, stageConf, s, c)
}

func DeployProjectsStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs BootstrapOutputs, c CommonConf) error {
	// shared
	sharedTfvars := ProjSharedTfvars{
		DefaultRegion: tfvars.DefaultRegion,
	}
	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, ProjectsStep, "shared.auto.tfvars"), sharedTfvars)
	if err != nil {
		return err
	}
	// common
	commonTfvars := ProjCommonTfvars{
		RemoteStateBucket: outputs.RemoteStateBucket,
	}
	err = utils.WriteTfvars(filepath.Join(c.FoundationPath, ProjectsStep, "common.auto.tfvars"), commonTfvars)
	if err != nil {
		return err
	}
	//for each environment
	envTfvars := ProjEnvTfvars{
		ProjectsKMSLocation: tfvars.ProjectsKMSLocation,
		ProjectsGCSLocation: tfvars.ProjectsGCSLocation,
	}
	for _, envfile := range []string{
		"development.auto.tfvars",
		"nonproduction.auto.tfvars",
		"production.auto.tfvars"} {
		err = utils.WriteTfvars(filepath.Join(c.FoundationPath, ProjectsStep, envfile), envTfvars)
		if err != nil {
			return err
		}
	}

	conf := utils.CloneCSR(t, ProjectsRepo, filepath.Join(c.CheckoutPath, ProjectsRepo), outputs.CICDProject, c.Logger)
	stageConf := StageConf{
		Stage:         ProjectsRepo,
		StageSA:       outputs.ProjectsSA,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          ProjectsStep,
		Repo:          ProjectsRepo,
		GitConf:       conf,
		HasManualStep: true,
		GroupingUnits: []string{"business_unit_1"},
		Envs:          []string{"production", "nonproduction", "development"},
	}

	return deployStage(t, stageConf, s, c)

}

func DeployExampleAppStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs InfraPipelineOutputs, c CommonConf) error {
	// create tfvars file
	commonTfvars := AppInfraCommonTfvars{
		InstanceRegion:    tfvars.DefaultRegion,
		RemoteStateBucket: outputs.RemoteStateBucket,
	}
	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, AppInfraStep, "common.auto.tfvars"), commonTfvars)
	if err != nil {
		return err
	}
	// update backend bucket
	for _, e := range []string{"production", "nonproduction", "development"} {
		err = utils.ReplaceStringInFile(filepath.Join(c.FoundationPath, AppInfraStep, "business_unit_1", e, "backend.tf"), "UPDATE_APP_INFRA_BUCKET", outputs.StateBucket)
		if err != nil {
			return err
		}
	}
	//prepare policies repo
	gcpPoliciesPath := filepath.Join(c.CheckoutPath, "gcp-policies-app-infra")
	policiesConf := utils.CloneCSR(t, PoliciesRepo, gcpPoliciesPath, outputs.InfraPipeProj, c.Logger)
	policiesBranch := "main"
	err = s.RunStep("bu1-example-app.gcp-policies-app-infra", func() error {
		return preparePoliciesRepo(policiesConf, policiesBranch, c.FoundationPath, gcpPoliciesPath)
	})
	if err != nil {
		return err
	}

	conf := utils.CloneCSR(t, AppInfraRepo, filepath.Join(c.CheckoutPath, AppInfraRepo), outputs.InfraPipeProj, c.Logger)
	stageConf := StageConf{
		Stage:         AppInfraRepo,
		CICDProject:   outputs.InfraPipeProj,
		DefaultRegion: outputs.DefaultRegion,
		Step:          AppInfraStep,
		Repo:          AppInfraRepo,
		GitConf:       conf,
		Envs:          []string{"production", "nonproduction", "development"},
	}

	return deployStage(t, stageConf, s, c)
}

func deployStage(t testing.TB, sc StageConf, s steps.Steps, c CommonConf) error {

	err := sc.GitConf.CheckoutBranch("plan")
	if err != nil {
		return err
	}

	err = s.RunStep(fmt.Sprintf("%s.copy-code", sc.Stage), func() error {
		return copyStepCode(t, sc.GitConf, c.FoundationPath, c.CheckoutPath, sc.Repo, sc.Step, sc.CustomTargetDirPath)
	})
	if err != nil {
		return err
	}

	shared := []string{}
	if sc.HasManualStep {
		shared = sc.GroupingUnits
	}
	for _, bu := range shared {
		buOptions := &terraform.Options{
			TerraformDir: filepath.Join(filepath.Join(c.CheckoutPath, sc.Repo), bu, "shared"),
			Logger:       c.Logger,
			NoColor:      true,
		}

		err := s.RunStep(fmt.Sprintf("%s.%s.apply-shared", sc.Stage, bu), func() error {
			return applyLocal(t, buOptions, sc.StageSA, c.PolicyPath, c.ValidatorProject)
		})
		if err != nil {
			return err
		}
	}

	err = s.RunStep(fmt.Sprintf("%s.plan", sc.Stage), func() error {
		return planStage(t, sc.GitConf, sc.CICDProject, sc.DefaultRegion, sc.Repo)
	})
	if err != nil {
		return err
	}

	for _, env := range sc.Envs {
		err = s.RunStep(fmt.Sprintf("%s.%s", sc.Stage, env), func() error {
			aEnv := env
			if env == "shared" {
				aEnv = "production"
			}
			return applyEnv(t, sc.GitConf, sc.CICDProject, sc.DefaultRegion, sc.Repo, aEnv)
		})
		if err != nil {
			return err
		}
	}

	fmt.Println("end of", sc.Step, "deploy")
	return nil
}

func preparePoliciesRepo(policiesConf utils.GitRepo, policiesBranch, foundationPath, gcpPoliciesPath string) error {
	err := policiesConf.CheckoutBranch(policiesBranch)
	if err != nil {
		return err
	}
	err = utils.CopyDirectory(filepath.Join(foundationPath, "policy-library"), gcpPoliciesPath)
	if err != nil {
		return err
	}
	err = policiesConf.CommitFiles("Initialize policy library repo")
	if err != nil {
		return err
	}
	return policiesConf.PushBranch(policiesBranch, "origin")
}

func copyStepCode(t testing.TB, conf utils.GitRepo, foundationPath, checkoutPath, repo, step, customPath string) error {
	gcpPath := filepath.Join(checkoutPath, repo)
	targetDir := gcpPath
	if customPath != "" {
		targetDir = filepath.Join(gcpPath, customPath)
	}
	err := utils.CopyDirectory(filepath.Join(foundationPath, step), targetDir)
	if err != nil {
		return err
	}
	err = utils.CopyFile(filepath.Join(foundationPath, "build/cloudbuild-tf-apply.yaml"), filepath.Join(gcpPath, "cloudbuild-tf-apply.yaml"))
	if err != nil {
		return err
	}
	err = utils.CopyFile(filepath.Join(foundationPath, "build/cloudbuild-tf-plan.yaml"), filepath.Join(gcpPath, "cloudbuild-tf-plan.yaml"))
	if err != nil {
		return err
	}
	return utils.CopyFile(filepath.Join(foundationPath, "build/tf-wrapper.sh"), filepath.Join(gcpPath, "tf-wrapper.sh"))
}

func planStage(t testing.TB, conf utils.GitRepo, project, region, repo string) error {
	err := conf.CommitFiles(fmt.Sprintf("Initialize %s repo", repo))
	if err != nil {
		return err
	}
	err = conf.PushBranch("plan", "origin")
	if err != nil {
		return err
	}

	commitSha, err := conf.GetCommitSha()
	if err != nil {
		return err
	}

	return gcp.NewGCP().WaitBuildSuccess(t, project, region, repo, commitSha, fmt.Sprintf("Terraform %s plan build Failed.", repo), MaxBuildRetries)
}

func saveBootstrapCodeOnly(t testing.TB, sc StageConf, s steps.Steps, c CommonConf) error {

	err := sc.GitConf.CheckoutBranch("plan")
	if err != nil {
		return err
	}

	err = s.RunStep(fmt.Sprintf("%s.copy-code", sc.Stage), func() error {
		return copyStepCode(t, sc.GitConf, c.FoundationPath, c.CheckoutPath, sc.Repo, sc.Step, sc.CustomTargetDirPath)
	})
	if err != nil {
		return err
	}

	err = s.RunStep(fmt.Sprintf("%s.plan", sc.Stage), func() error {
		err := sc.GitConf.CommitFiles(fmt.Sprintf("Initialize %s repo", sc.Repo))
		if err != nil {
			return err
		}
		return sc.GitConf.PushBranch("plan", "origin")
	})

	if err != nil {
		return err
	}

	for _, env := range sc.Envs {
		err = s.RunStep(fmt.Sprintf("%s.%s", sc.Stage, env), func() error {
			aEnv := env
			if env == "shared" {
				aEnv = "production"
			}
			err := sc.GitConf.CheckoutBranch(aEnv)
			if err != nil {
				return err
			}
			return sc.GitConf.PushBranch(aEnv, "origin")
		})
		if err != nil {
			return err
		}
	}

	fmt.Println("end of", sc.Step, "deploy")
	return nil
}

func applyEnv(t testing.TB, conf utils.GitRepo, project, region, repo, environment string) error {
	err := conf.CheckoutBranch(environment)
	if err != nil {
		return err
	}
	err = conf.PushBranch(environment, "origin")
	if err != nil {
		return err
	}
	commitSha, err := conf.GetCommitSha()
	if err != nil {
		return err
	}

	return gcp.NewGCP().WaitBuildSuccess(t, project, region, repo, commitSha, fmt.Sprintf("Terraform %s apply %s build Failed.", repo, environment), MaxBuildRetries)
}

func applyLocal(t testing.TB, options *terraform.Options, serviceAccount, policyPath, validatorProjectId string) error {
	var err error

	if serviceAccount != "" {
		err = os.Setenv("GOOGLE_IMPERSONATE_SERVICE_ACCOUNT", serviceAccount)
		if err != nil {
			return err
		}
	}

	_, err = terraform.InitE(t, options)
	if err != nil {
		return err
	}
	_, err = terraform.PlanE(t, options)
	if err != nil {
		return err
	}

	// Runs gcloud terraform vet
	if validatorProjectId != "" {
		err = TerraformVet(t, options.TerraformDir, policyPath, validatorProjectId)
		if err != nil {
			return err
		}
	}

	_, err = terraform.ApplyE(t, options)
	if err != nil {
		return err
	}

	if serviceAccount != "" {
		err = os.Unsetenv("GOOGLE_IMPERSONATE_SERVICE_ACCOUNT")
		if err != nil {
			return err
		}
	}
	return nil
}
