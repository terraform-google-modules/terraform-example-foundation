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
)

func DeployBootstrapStage(t testing.TB, s steps.Steps, tfvars GlobalTFVars, c CommonConf) error {
	bootstrapTfvars := BootstrapTfvars{
		OrgID:              tfvars.OrgID,
		DefaultRegion:      tfvars.DefaultRegion,
		BillingAccount:     tfvars.BillingAccount,
		GroupOrgAdmins:     tfvars.GroupOrgAdmins,
		GroupBillingAdmins: tfvars.GroupBillingAdmins,
		ParentFolder:       tfvars.ParentFolder,
		ProjectPrefix:      tfvars.ProjectPrefix,
		FolderPrefix:       tfvars.FolderPrefix,
		BucketForceDestroy: tfvars.BucketForceDestroy,
	}

	err := utils.WriteTfvars(filepath.Join(c.FoundationPath, BootstrapStep, "terraform.tfvars"), bootstrapTfvars)
	if err != nil {
		return err
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
		err = policiesConf.CheckoutBranch(policiesBranch)
		if err != nil {
			return err
		}
		err = utils.CopyDirectory(filepath.Join(c.FoundationPath, "policy-library"), gcpPoliciesPath)
		if err != nil {
			return err
		}
		err = policiesConf.CommitFiles("Initialize policy library repo")
		if err != nil {
			return err
		}
		return policiesConf.PushBranch(policiesBranch, "origin")
	})
	if err != nil {
		return err
	}

	//prepare bootstrap repo
	gcpBootstrapPath := filepath.Join(c.CheckoutPath, BootstrapRepo)
	bootstrapConf := utils.CloneCSR(t, BootstrapRepo, gcpBootstrapPath, cbProjectID, c.Logger)
	err = bootstrapConf.CheckoutBranch("plan")
	if err != nil {
		return err
	}

	err = s.RunStep("gcp-bootstrap.copy-code", func() error {
		return copyStepCode(t, bootstrapConf, c.FoundationPath, c.CheckoutPath, BootstrapRepo, BootstrapStep, "envs/shared")
	})
	if err != nil {
		return err
	}

	err = s.RunStep("gcp-bootstrap.plan", func() error {
		return planStage(t, bootstrapConf, cbProjectID, defaultRegion, BootstrapRepo)
	})
	if err != nil {
		return err
	}

	err = s.RunStep("gcp-bootstrap.production", func() error {
		return applyEnv(t, bootstrapConf, cbProjectID, defaultRegion, BootstrapRepo, "production")
	})
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
