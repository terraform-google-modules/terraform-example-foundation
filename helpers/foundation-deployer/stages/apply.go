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
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/gitlab"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/msg"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/steps"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"
)

func buildGitLabCICDImage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, c CommonConf) error {
	gl := gitlab.NewGL()
	cicdPath := filepath.Join(c.CheckoutPath, "gcp-cicd-runner")
	repoURL := utils.BuildGitLabURL(tfvars.GitRepos.Owner, *tfvars.GitRepos.CICDRunner, c.GitToken)

	conf := utils.GitClone(t, tfvars.BuildType, "", repoURL, cicdPath, "", c.Logger)
	err := conf.CheckoutBranch("image")
	if err != nil {
		return err
	}

	err = utils.CopyFile(filepath.Join(c.FoundationPath, "build/gitlab-ci.yml"), filepath.Join(cicdPath, ".gitlab-ci.yml"))
	if err != nil {
		return err
	}

	err = utils.CopyFile(filepath.Join(c.FoundationPath, "0-bootstrap/Dockerfile"), filepath.Join(cicdPath, "Dockerfile"))
	if err != nil {
		return err
	}

	err = conf.CommitFiles("Initialize CI/CD runner project")
	if err != nil {
		return err
	}
	err = conf.PushBranch("image", "origin")
	if err != nil {
		return err
	}

	commitSha, err := conf.GetCommitSha()
	if err != nil {
		return err
	}

	fmt.Println("")
	fmt.Println("# Follow job execution in GitLab:")
	fmt.Printf("# %s\n", fmt.Sprintf("https://gitlab.com/%s/%s/-/jobs", tfvars.GitRepos.Owner, *tfvars.GitRepos.CICDRunner))

	failureMsg := fmt.Sprintf("CI/CD runner image job failed %s/%s repository.", tfvars.GitRepos.Owner, *tfvars.GitRepos.CICDRunner)
	err = gl.WaitBuildSuccess(t, tfvars.GitRepos.Owner, *tfvars.GitRepos.CICDRunner, c.GitToken, commitSha, failureMsg, MaxBuildRetries, MaxErrorRetries, TimeBetweenErrorRetries)
	if err != nil {
		return err
	}

	projectsToAdd := make([]string, 5)
	projectsToAdd[0] = tfvars.GitRepos.Bootstrap
	projectsToAdd[1] = tfvars.GitRepos.Organization
	projectsToAdd[2] = tfvars.GitRepos.Environments
	projectsToAdd[3] = tfvars.GitRepos.Networks
	projectsToAdd[4] = tfvars.GitRepos.Projects

	return gl.AddProjectsToJobTokenScope(t, tfvars.GitRepos.Owner, *tfvars.GitRepos.CICDRunner, c.GitToken, projectsToAdd)
}

func DeployBootstrapStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, c CommonConf) error {

	var err error
	var envVars map[string]string

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
		WorkflowDeletionProtection:   tfvars.WorkflowDeletionProtection,
		Groups:                       tfvars.Groups,
		InitialGroupConfig:           tfvars.InitialGroupConfig,
		FolderDeletionProtection:     tfvars.FolderDeletionProtection,
		ProjectDeletionPolicy:        tfvars.ProjectDeletionPolicy,
	}

	if tfvars.BuildType == BuildTypeGiHub {
		bootstrapTfvars.GitHubRepos = &GitHubRepos{
			Owner:        tfvars.GitRepos.Owner,
			Bootstrap:    tfvars.GitRepos.Bootstrap,
			Organization: tfvars.GitRepos.Organization,
			Environments: tfvars.GitRepos.Environments,
			Networks:     tfvars.GitRepos.Networks,
			Projects:     tfvars.GitRepos.Projects,
		}
		envVars = map[string]string{
			"TF_VAR_gh_token": c.GitToken,
		}
	}

	if tfvars.BuildType == BuildTypeGitLab {
		bootstrapTfvars.GitLabRepos = &GitLabRepos{
			Owner:        tfvars.GitRepos.Owner,
			Bootstrap:    tfvars.GitRepos.Bootstrap,
			Organization: tfvars.GitRepos.Organization,
			Environments: tfvars.GitRepos.Environments,
			Networks:     tfvars.GitRepos.Networks,
			Projects:     tfvars.GitRepos.Projects,
			CICDRunner:   *tfvars.GitRepos.CICDRunner,
		}
		envVars = map[string]string{
			"TF_VAR_gitlab_token": c.GitToken,
		}
	}

	err = utils.RenameBuildFiles(filepath.Join(c.FoundationPath, BootstrapStep), tfvars.BuildType)
	if err != nil {
		return err
	}

	err = utils.WriteTfvars(filepath.Join(c.FoundationPath, BootstrapStep, "terraform.tfvars"), bootstrapTfvars)
	if err != nil {
		return err
	}

	terraformDir := filepath.Join(c.FoundationPath, BootstrapStep)
	options := &terraform.Options{
		TerraformDir:             terraformDir,
		Logger:                   c.Logger,
		NoColor:                  true,
		RetryableTerraformErrors: testutils.RetryableTransientErrors,
		MaxRetries:               MaxErrorRetries,
		TimeBetweenRetries:       TimeBetweenErrorRetries,
		EnvVars:                  envVars,
	}

	// terraform deploy
	err = applyLocal(t, options, "", c.PolicyPath, c.ValidatorProject)
	if err != nil {
		return err
	}

	// read bootstrap outputs
	defaultRegion := terraform.OutputMap(t, options, "common_config")["default_region"]
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

	var stageConf StageConf
	var cbProjectID string
	var executor Executor
	var bootstrapConf utils.GitRepo

	gcpBootstrapPath := filepath.Join(c.CheckoutPath, BootstrapRepo)

	if tfvars.BuildType == BuildTypeCBCSR {
		cbProjectID = terraform.Output(t, options, "cloudbuild_project_id")

		msg.PrintBuildMsg(cbProjectID, defaultRegion, c.DisablePrompt)

		// Check if image build was successful.
		buildTFBuilderExecutor := NewGCPExecutor(cbProjectID, defaultRegion, "tf-cloudbuilder")
		err = buildTFBuilderExecutor.WaitBuildSuccess(t, "", "Terraform Image builder Build Failed for tf-cloudbuilder repository.")
		if err != nil {
			return err
		}

		//prepare policies repo
		gcpPoliciesPath := filepath.Join(c.CheckoutPath, PoliciesRepo)
		policiesConf := utils.GitClone(t, "CSR", PoliciesRepo, "", gcpPoliciesPath, cbProjectID, c.Logger)
		policiesBranch := "main"

		err = s.RunStep("gcp-bootstrap.gcp-policies", func() error {
			return preparePoliciesRepo(policiesConf, policiesBranch, c.FoundationPath, gcpPoliciesPath)
		})
		if err != nil {
			return err
		}

		bootstrapConf = utils.GitClone(t, "CSR", BootstrapRepo, "", gcpBootstrapPath, cbProjectID, c.Logger)
		executor = NewGCPExecutor(cbProjectID, defaultRegion, BootstrapRepo)
	}

	if tfvars.BuildType == BuildTypeGiHub {
		executor = NewGitHubExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Bootstrap, c.GitToken)
		repoURL := utils.BuildGitHubURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Bootstrap, c.GitToken)
		bootstrapConf = utils.GitClone(t, tfvars.BuildType, "", repoURL, gcpBootstrapPath, cbProjectID, c.Logger)

	}

	if tfvars.BuildType == BuildTypeGitLab {

		err = s.RunStep("gcp-bootstrap.build-cicd-runner", func() error {
			return buildGitLabCICDImage(t, s, tfvars, c)
		})
		if err != nil {
			return err
		}

		executor = NewGitLabExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Bootstrap, c.GitToken)
		repoURL := utils.BuildGitLabURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Bootstrap, c.GitToken)
		bootstrapConf = utils.GitClone(t, tfvars.BuildType, "", repoURL, gcpBootstrapPath, cbProjectID, c.Logger)
	}

	stageConf = StageConf{
		Stage:               BootstrapRepo,
		CICDProject:         cbProjectID,
		DefaultRegion:       defaultRegion,
		Step:                BootstrapStep,
		Repo:                BootstrapRepo,
		CustomTargetDirPath: "envs/shared",
		GitConf:             bootstrapConf,
		Envs:                []string{"shared"},
		BuildType:           tfvars.BuildType,
		Executor:            executor,
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
			TerraformDir:             filepath.Join(gcpBootstrapPath, "envs", "shared"),
			Logger:                   c.Logger,
			NoColor:                  true,
			RetryableTerraformErrors: testutils.RetryableTransientErrors,
			MaxRetries:               MaxErrorRetries,
			TimeBetweenRetries:       TimeBetweenErrorRetries,
			EnvVars:                  envVars,
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
		EnableSccResourcesInTerraform:         tfvars.EnableSccResourcesInTerraform,
		LogExportStorageForceDestroy:          tfvars.LogExportStorageForceDestroy,
		LogExportStorageLocation:              tfvars.LogExportStorageLocation,
		BillingExportDatasetLocation:          tfvars.BillingExportDatasetLocation,
		FolderDeletionProtection:              tfvars.FolderDeletionProtection,
		ProjectDeletionPolicy:                 tfvars.ProjectDeletionPolicy,
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

	var conf utils.GitRepo
	var executor Executor

	switch c.BuildType {
	case BuildTypeGiHub:
		executor = NewGitHubExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Organization, c.GitToken)
		repoURL := utils.BuildGitHubURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Organization, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, OrgRepo), "", c.Logger)
	case BuildTypeGitLab:
		executor = NewGitLabExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Organization, c.GitToken)
		repoURL := utils.BuildGitLabURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Organization, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, OrgRepo), "", c.Logger)
	default:
		executor = NewGCPExecutor(outputs.CICDProject, outputs.DefaultRegion, OrgRepo)
		conf = utils.GitClone(t, "CSR", OrgRepo, "", filepath.Join(c.CheckoutPath, OrgRepo), outputs.CICDProject, c.Logger)
	}

	stageConf := StageConf{
		Stage:         OrgRepo,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          OrgStep,
		Repo:          OrgRepo,
		GitConf:       conf,
		Envs:          []string{"shared"},
		BuildType:     c.BuildType,
		Executor:      executor,
	}

	return deployStage(t, stageConf, s, c)
}

func DeployEnvStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs BootstrapOutputs, c CommonConf) error {

	envsTfvars := EnvsTfvars{
		RemoteStateBucket:        outputs.RemoteStateBucket,
		FolderDeletionProtection: tfvars.FolderDeletionProtection,
		ProjectDeletionPolicy:    tfvars.ProjectDeletionPolicy,
	}
	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, EnvironmentsStep, "terraform.tfvars"), envsTfvars)
	if err != nil {
		return err
	}

	var conf utils.GitRepo
	var executor Executor

	switch c.BuildType {
	case BuildTypeGiHub:
		executor = NewGitHubExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Environments, c.GitToken)
		repoURL := utils.BuildGitHubURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Environments, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, EnvironmentsRepo), "", c.Logger)
	case BuildTypeGitLab:
		executor = NewGitLabExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Environments, c.GitToken)
		repoURL := utils.BuildGitLabURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Environments, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, EnvironmentsRepo), "", c.Logger)
	default:
		executor = NewGCPExecutor(outputs.CICDProject, outputs.DefaultRegion, EnvironmentsRepo)
		conf = utils.GitClone(t, "CSR", EnvironmentsRepo, "", filepath.Join(c.CheckoutPath, EnvironmentsRepo), outputs.CICDProject, c.Logger)
	}

	stageConf := StageConf{
		Stage:         EnvironmentsRepo,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          EnvironmentsStep,
		Repo:          EnvironmentsRepo,
		GitConf:       conf,
		Envs:          []string{"production", "nonproduction", "development"},
		BuildType:     c.BuildType,
		Executor:      executor,
	}

	return deployStage(t, stageConf, s, c)
}

func DeployNetworksStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs BootstrapOutputs, c CommonConf) error {

	step := GetNetworkStep(c.EnableHubAndSpoke)

	var localStep []string

	if c.EnableHubAndSpoke {
		localStep = []string{"shared"}
	} else {
		localStep = []string{"shared", "production"}
	}

	// shared
	sharedTfvars := NetSharedTfvars{
		TargetNameServerAddresses: tfvars.TargetNameServerAddresses,
	}
	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, step, "shared.auto.tfvars"), sharedTfvars)
	if err != nil {
		return err
	}
	// production
	productionTfvars := NetProductionTfvars{
		TargetNameServerAddresses: tfvars.TargetNameServerAddresses,
	}
	err = utils.WriteTfvars(filepath.Join(c.FoundationPath, step, "production.auto.tfvars"), productionTfvars)
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

	var conf utils.GitRepo
	var executor Executor

	switch c.BuildType {
	case BuildTypeGiHub:
		executor = NewGitHubExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Networks, c.GitToken)
		repoURL := utils.BuildGitHubURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Networks, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, NetworksRepo), "", c.Logger)
	case BuildTypeGitLab:
		executor = NewGitLabExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Networks, c.GitToken)
		repoURL := utils.BuildGitLabURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Networks, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, NetworksRepo), "", c.Logger)
	default:
		executor = NewGCPExecutor(outputs.CICDProject, outputs.DefaultRegion, NetworksRepo)
		conf = utils.GitClone(t, "CSR", NetworksRepo, "", filepath.Join(c.CheckoutPath, NetworksRepo), outputs.CICDProject, c.Logger)
	}

	stageConf := StageConf{
		Stage:         NetworksRepo,
		StageSA:       outputs.NetworkSA,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          step,
		Repo:          NetworksRepo,
		GitConf:       conf,
		HasLocalStep:  true,
		LocalSteps:    localStep,
		GroupingUnits: []string{"envs"},
		Envs:          []string{"production", "nonproduction", "development"},
		BuildType:     c.BuildType,
		Executor:      executor,
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
		LocationKMS:              tfvars.LocationKMS,
		LocationGCS:              tfvars.LocationGCS,
		FolderDeletionProtection: tfvars.FolderDeletionProtection,
		ProjectDeletionPolicy:    tfvars.ProjectDeletionPolicy,
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

	var conf utils.GitRepo
	var executor Executor

	switch c.BuildType {
	case BuildTypeGiHub:
		executor = NewGitHubExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Projects, c.GitToken)
		repoURL := utils.BuildGitHubURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Projects, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, ProjectsRepo), "", c.Logger)
	case BuildTypeGitLab:
		executor = NewGitLabExecutor(tfvars.GitRepos.Owner, tfvars.GitRepos.Projects, c.GitToken)
		repoURL := utils.BuildGitLabURL(tfvars.GitRepos.Owner, tfvars.GitRepos.Projects, c.GitToken)
		conf = utils.GitClone(t, tfvars.BuildType, "", repoURL, filepath.Join(c.CheckoutPath, ProjectsRepo), "", c.Logger)
	default:
		executor = NewGCPExecutor(outputs.CICDProject, outputs.DefaultRegion, ProjectsRepo)
		conf = utils.GitClone(t, "CSR", ProjectsRepo, "", filepath.Join(c.CheckoutPath, ProjectsRepo), outputs.CICDProject, c.Logger)
	}

	stageConf := StageConf{
		Stage:         ProjectsRepo,
		StageSA:       outputs.ProjectsSA,
		CICDProject:   outputs.CICDProject,
		DefaultRegion: outputs.DefaultRegion,
		Step:          ProjectsStep,
		Repo:          ProjectsRepo,
		GitConf:       conf,
		HasLocalStep:  true,
		LocalSteps:    []string{"shared"},
		GroupingUnits: []string{"business_unit_1"},
		Envs:          []string{"production", "nonproduction", "development"},
		BuildType:     c.BuildType,
		Executor:      executor,
	}

	return deployStage(t, stageConf, s, c)

}

func DeployExampleAppStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, outputs InfraPipelineOutputs, c CommonConf) error {
	digest, err := gcp.NewGCP().GetDockerImageDigest(t, outputs.BootstrapCloudbuildProjectID, outputs.ImageName)
	if err != nil {
		return err
	}
	// create tfvars file
	commonTfvars := AppInfraCommonTfvars{
		InstanceRegion:    tfvars.DefaultRegion,
		RemoteStateBucket: outputs.RemoteStateBucket,
		ImageDigest:       digest,
	}
	err = utils.WriteTfvars(filepath.Join(c.FoundationPath, AppInfraStep, "common.auto.tfvars"), commonTfvars)
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
	gcpPoliciesPath := filepath.Join(c.CheckoutPath, "gcp-policies-app-infra")
	policiesConf := utils.GitClone(t, "CSR", PoliciesRepo, "", gcpPoliciesPath, outputs.InfraPipeProj, c.Logger)
	policiesBranch := "main"
	err = s.RunStep("bu1-example-app.gcp-policies-app-infra", func() error {
		return preparePoliciesRepo(policiesConf, policiesBranch, c.FoundationPath, gcpPoliciesPath)
	})
	if err != nil {
		return err
	}

	executor := NewGCPExecutor(outputs.InfraPipeProj, outputs.DefaultRegion, AppInfraRepo)
	conf := utils.GitClone(t, "CSR", AppInfraRepo, "", filepath.Join(c.CheckoutPath, AppInfraRepo), outputs.InfraPipeProj, c.Logger)
	stageConf := StageConf{
		Stage:         AppInfraRepo,
		CICDProject:   outputs.InfraPipeProj,
		DefaultRegion: outputs.DefaultRegion,
		Step:          AppInfraStep,
		Repo:          AppInfraRepo,
		GitConf:       conf,
		Envs:          []string{"production", "nonproduction", "development"},
		BuildType:     c.BuildType,
		Executor:      executor,
	}

	return deployStage(t, stageConf, s, c)
}

func deployStage(t testing.TB, sc StageConf, s steps.Steps, c CommonConf) error {

	err := sc.GitConf.CheckoutBranch("plan")
	if err != nil {
		return err
	}

	err = s.RunStep(fmt.Sprintf("%s.copy-code", sc.Stage), func() error {
		return copyStepCode(t, sc.GitConf, c.FoundationPath, c.CheckoutPath, sc.Repo, sc.Step, sc.CustomTargetDirPath, sc.BuildType)
	})
	if err != nil {
		return err
	}

	groupunit := []string{}
	if sc.HasLocalStep {
		groupunit = sc.GroupingUnits
	}

	for _, bu := range groupunit {
		for _, localStep := range sc.LocalSteps {
			buOptions := &terraform.Options{
				TerraformDir:             filepath.Join(filepath.Join(c.CheckoutPath, sc.Repo), bu, localStep),
				Logger:                   c.Logger,
				NoColor:                  true,
				RetryableTerraformErrors: testutils.RetryableTransientErrors,
				MaxRetries:               MaxErrorRetries,
				TimeBetweenRetries:       TimeBetweenErrorRetries,
			}

			err := s.RunStep(fmt.Sprintf("%s.%s.apply-%s", sc.Stage, bu, localStep), func() error {
				return applyLocal(t, buOptions, sc.StageSA, c.PolicyPath, c.ValidatorProject)
			})
			if err != nil {
				return err
			}
		}
	}

	err = s.RunStep(fmt.Sprintf("%s.plan", sc.Stage), func() error {
		return planStage(t, sc.GitConf, sc.CICDProject, sc.DefaultRegion, sc.Repo, sc.Executor)
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
			return applyEnv(t, sc.GitConf, sc.CICDProject, sc.DefaultRegion, sc.Repo, aEnv, sc.Executor)
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

func copyStepCode(t testing.TB, conf utils.GitRepo, foundationPath, checkoutPath, repo, step, customPath, buildType string) error {
	gcpPath := filepath.Join(checkoutPath, repo)
	targetDir := gcpPath
	if customPath != "" {
		targetDir = filepath.Join(gcpPath, customPath)
	}

	err := utils.CopyDirectory(filepath.Join(foundationPath, step), targetDir)
	if err != nil {
		return err
	}

	if buildType != BuildTypeCBCSR {
		err := utils.CopyDirectory(filepath.Join(foundationPath, "policy-library"), filepath.Join(gcpPath, "policy-library"))
		if err != nil {
			return err
		}
	}

	switch buildType {
	case BuildTypeGiHub:
		err = os.MkdirAll(filepath.Join(gcpPath, ".github/workflows/"), 0755)
		if err != nil {
			return err
		}
		err = utils.CopyFile(filepath.Join(foundationPath, "build/github-tf-apply.yaml"), filepath.Join(gcpPath, ".github/workflows/github-tf-apply.yaml"))
		if err != nil {
			return err
		}
		err = utils.CopyFile(filepath.Join(foundationPath, "build/github-tf-plan-all.yaml"), filepath.Join(gcpPath, ".github/workflows/github-tf-plan-all.yaml"))
		if err != nil {
			return err
		}
		err = utils.CopyFile(filepath.Join(foundationPath, "build/github-tf-pull-request.yaml"), filepath.Join(gcpPath, ".github/workflows/github-tf-pull-request.yaml"))
		if err != nil {
			return err
		}
	case BuildTypeGitLab:
		err = utils.CopyFile(filepath.Join(foundationPath, "build/gitlab-ci.yml"), filepath.Join(gcpPath, ".gitlab-ci.yml"))
		if err != nil {
			return err
		}
		err = utils.CopyFile(filepath.Join(foundationPath, "build/run_gcp_auth.sh"), filepath.Join(gcpPath, "run_gcp_auth.sh"))
		if err != nil {
			return err
		}
	default: //BuildTypeCBCSR
		err = utils.CopyFile(filepath.Join(foundationPath, "build/cloudbuild-tf-apply.yaml"), filepath.Join(gcpPath, "cloudbuild-tf-apply.yaml"))
		if err != nil {
			return err
		}
		err = utils.CopyFile(filepath.Join(foundationPath, "build/cloudbuild-tf-plan.yaml"), filepath.Join(gcpPath, "cloudbuild-tf-plan.yaml"))
		if err != nil {
			return err
		}
	}

	return utils.CopyFile(filepath.Join(foundationPath, "build/tf-wrapper.sh"), filepath.Join(gcpPath, "tf-wrapper.sh"))
}

func planStage(t testing.TB, conf utils.GitRepo, project, region, repo string, buildExecutor Executor) error {

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

	return buildExecutor.WaitBuildSuccess(t, commitSha, fmt.Sprintf("Terraform %s plan build Failed.", repo))
}

func saveBootstrapCodeOnly(t testing.TB, sc StageConf, s steps.Steps, c CommonConf) error {

	err := sc.GitConf.CheckoutBranch("plan")
	if err != nil {
		return err
	}

	err = s.RunStep(fmt.Sprintf("%s.copy-code", sc.Stage), func() error {
		return copyStepCode(t, sc.GitConf, c.FoundationPath, c.CheckoutPath, sc.Repo, sc.Step, sc.CustomTargetDirPath, sc.BuildType)
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

func applyEnv(t testing.TB, conf utils.GitRepo, project, region, repo, environment string, buildExecutor Executor) error {
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

	return buildExecutor.WaitBuildSuccess(t, commitSha, fmt.Sprintf("Terraform %s apply %s build Failed.", repo, environment))
}

func applyLocal(t testing.TB, options *terraform.Options, serviceAccount, policyPath, validatorProjectID string) error {
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
	if validatorProjectID != "" {
		err = TerraformVet(t, options.TerraformDir, policyPath, validatorProjectID, options.EnvVars)
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
