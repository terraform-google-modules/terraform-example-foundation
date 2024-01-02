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

package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	gotest "testing"
	"time"

	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/gcp"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/msg"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/stages"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/steps"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/utils"
)

var (
	validatorApis = []string{
		"securitycenter.googleapis.com",
		"accesscontextmanager.googleapis.com",
	}
)

type cfg struct {
	tfvarsFile    string
	stepsFile     string
	resetStep     string
	quiet         bool
	help          bool
	listSteps     bool
	disablePrompt bool
	validate      bool
	destroy       bool
}

func parseFlags() cfg {
	var c cfg

	flag.StringVar(&c.tfvarsFile, "tfvars_file", "", "Full path to the Terraform .tfvars `file` with the configuration to be used.")
	flag.StringVar(&c.stepsFile, "steps_file", ".steps.json", "Path to the steps `file` to be used to save progress.")
	flag.StringVar(&c.resetStep, "reset_step", "", "Name of a `step` to be reset. The step will be marked as pending.")
	flag.BoolVar(&c.quiet, "quiet", false, "If true, additional output is suppressed.")
	flag.BoolVar(&c.help, "help", false, "Prints this help text and exits.")
	flag.BoolVar(&c.listSteps, "list_steps", false, "List the existing steps.")
	flag.BoolVar(&c.disablePrompt, "disable_prompt", false, "Disable interactive prompt.")
	flag.BoolVar(&c.validate, "validate", false, "Validate tfvars file inputs.")
	flag.BoolVar(&c.destroy, "destroy", false, "Destroy the deployment.")

	flag.Parse()
	return c
}

func main() {

	cfg := parseFlags()
	if cfg.help {
		fmt.Println("Deploys the Terraform Example Foundation")
		flag.PrintDefaults()
		return
	}

	// load tfvars
	globalTFVars, err := stages.ReadGlobalTFVars(cfg.tfvarsFile)
	if err != nil {
		fmt.Printf("# Failed to read GlobalTFVars file. Error: %s\n", err.Error())
		os.Exit(1)
	}

	// validate Directories
	err = stages.ValidateDirectories(globalTFVars)
	if err != nil {
		fmt.Printf("# Failed validating directories. Error: %s\n", err.Error())
		os.Exit(1)
	}

	// init infra
	gotest.Init()
	t := &testing.RuntimeT{}
	conf := stages.CommonConf{
		FoundationPath:    globalTFVars.FoundationCodePath,
		CheckoutPath:      globalTFVars.CodeCheckoutPath,
		PolicyPath:        filepath.Join(globalTFVars.FoundationCodePath, "policy-library"),
		EnableHubAndSpoke: globalTFVars.EnableHubAndSpoke,
		DisablePrompt:     cfg.disablePrompt,
		Logger:            utils.GetLogger(cfg.quiet),
	}

	// only enable services if they are not already enabled
	if globalTFVars.HasValidatorProj() {
		conf.ValidatorProject = *globalTFVars.ValidatorProjectId
		var apis []string
		gcpConf := gcp.NewGCP()
		for _, a := range validatorApis {
			if !gcpConf.IsApiEnabled(t, *globalTFVars.ValidatorProjectId, a) {
				apis = append(apis, a)
			}
		}
		if len(apis) > 0 {
			fmt.Printf("# Enabling APIs: %s in validator project '%s'\n", strings.Join(apis, ", "), *globalTFVars.ValidatorProjectId)
			gcpConf.EnableApis(t, *globalTFVars.ValidatorProjectId, apis)
			fmt.Println("# waiting for API propagation")
			for i := 0; i < 20; i++ {
				time.Sleep(10 * time.Second)
				fmt.Println("# waiting for API propagation")
			}
		}
	}

	// validate inputs
	if cfg.validate {
		stages.ValidateBasicFields(t, globalTFVars)
		stages.ValidateDestroyFlags(t, globalTFVars)
		return
	}

	s, err := steps.LoadSteps(cfg.stepsFile)
	if err != nil {
		fmt.Printf("# failed to load state file %s. Error: %s\n", cfg.stepsFile, err.Error())
		os.Exit(2)
	}

	if cfg.listSteps {
		fmt.Println("# Executed steps:")
		e := s.ListSteps()
		if len(e) == 0 {
			fmt.Println("# No steps executed")
			return
		}
		for _, step := range e {
			fmt.Println(step)
		}
		return
	}

	if cfg.resetStep != "" {
		if err := s.ResetStep(cfg.resetStep); err != nil {
			fmt.Printf("# Reset step failed. Error: %s\n", err.Error())
			os.Exit(3)
		}
		return
	}

	// destroy stages
	if cfg.destroy {
		// Note: destroy is only terraform destroy, local directories are not deleted.
		// 5-app-infra
		msg.PrintStageMsg("Destroying 5-app-infra stage")
		err = s.RunDestroyStep("bu1-example-app", func() error {
			io := stages.GetInfraPipelineOutputs(t, conf.CheckoutPath, "bu1-example-app")
			return stages.DestroyExampleAppStage(t, s, io, conf)
		})
		if err != nil {
			fmt.Printf("# Example app step destroy failed. Error: %s\n", err.Error())
			os.Exit(3)
		}

		// 4-projects
		msg.PrintStageMsg("Destroying 4-projects stage")
		err = s.RunDestroyStep("gcp-projects", func() error {
			bo := stages.GetBootstrapStepOutputs(t, conf.FoundationPath)
			return stages.DestroyProjectsStage(t, s, bo, conf)
		})
		if err != nil {
			fmt.Printf("# Projects step destroy failed. Error: %s\n", err.Error())
			os.Exit(3)
		}

		// 3-networks
		msg.PrintStageMsg("Destroying 3-networks stage")
		err = s.RunDestroyStep("gcp-networks", func() error {
			bo := stages.GetBootstrapStepOutputs(t, conf.FoundationPath)
			return stages.DestroyNetworksStage(t, s, bo, conf)
		})
		if err != nil {
			fmt.Printf("# Networks step destroy failed. Error: %s\n", err.Error())
			os.Exit(3)
		}

		// 2-environments
		msg.PrintStageMsg("Destroying 2-environments stage")
		err = s.RunDestroyStep("gcp-environments", func() error {
			bo := stages.GetBootstrapStepOutputs(t, conf.FoundationPath)
			return stages.DestroyEnvStage(t, s, bo, conf)
		})
		if err != nil {
			fmt.Printf("# Environments step destroy failed. Error: %s\n", err.Error())
			os.Exit(3)
		}

		// 1-org
		msg.PrintStageMsg("Destroying 1-org stage")
		err = s.RunDestroyStep("gcp-org", func() error {
			bo := stages.GetBootstrapStepOutputs(t, conf.FoundationPath)
			return stages.DestroyOrgStage(t, s, bo, conf)
		})
		if err != nil {
			fmt.Printf("# Org step destroy failed. Error: %s\n", err.Error())
			os.Exit(3)
		}

		// 0-bootstrap
		msg.PrintStageMsg("Destroying 0-bootstrap stage")
		err = s.RunDestroyStep("gcp-bootstrap", func() error {
			return stages.DestroyBootstrapStage(t, s, conf)
		})
		if err != nil {
			fmt.Printf("# Bootstrap step destroy failed. Error: %s\n", err.Error())
			os.Exit(3)
		}

		// clean up the steps file
		err = steps.DeleteStepsFile(cfg.stepsFile)
		if err != nil {
			fmt.Printf("# failed to delete state file %s. Error: %s\n", cfg.stepsFile, err.Error())
			os.Exit(3)
		}
		return
	}

	// deploy stages

	// 0-bootstrap
	msg.PrintStageMsg("Deploying 0-bootstrap stage")
	skipInnerBuildMsg := s.IsStepComplete("gcp-bootstrap")
	err = s.RunStep("gcp-bootstrap", func() error {
		return stages.DeployBootstrapStage(t, s, globalTFVars, conf)
	})
	if err != nil {
		fmt.Printf("# Bootstrap step failed. Error: %s\n", err.Error())
		os.Exit(3)
	}

	bo := stages.GetBootstrapStepOutputs(t, conf.FoundationPath)

	if skipInnerBuildMsg {
		msg.PrintBuildMsg(bo.CICDProject, bo.DefaultRegion, conf.DisablePrompt)
	}
	msg.PrintQuotaMsg(bo.ProjectsSA, conf.DisablePrompt)
	if globalTFVars.HasGroupsCreation() {
		msg.PrintAdminGroupPermissionMsg(bo.BootstrapSA, conf.DisablePrompt)
	}

	// 1-org
	msg.PrintStageMsg("Deploying 1-org stage")
	err = s.RunStep("gcp-org", func() error {
		return stages.DeployOrgStage(t, s, globalTFVars, bo, conf)
	})
	if err != nil {
		fmt.Printf("# Org step failed. Error: %s\n", err.Error())
		os.Exit(3)
	}

	// 2-environments
	msg.PrintStageMsg("Deploying 2-environments stage")
	err = s.RunStep("gcp-environments", func() error {
		return stages.DeployEnvStage(t, s, globalTFVars, bo, conf)
	})
	if err != nil {
		fmt.Printf("# Environments step failed. Error: %s\n", err.Error())
		os.Exit(3)
	}

	// 3-networks
	msg.PrintStageMsg("Deploying 3-networks stage")
	err = s.RunStep("gcp-networks", func() error {
		return stages.DeployNetworksStage(t, s, globalTFVars, bo, conf)
	})
	if err != nil {
		fmt.Printf("# Networks step failed. Error: %s\n", err.Error())
		os.Exit(3)
	}

	// 4-projects
	msg.PrintStageMsg("Deploying 4-projects stage")
	msg.ConfirmQuota(bo.ProjectsSA, conf.DisablePrompt)

	err = s.RunStep("gcp-projects", func() error {
		return stages.DeployProjectsStage(t, s, globalTFVars, bo, conf)
	})
	if err != nil {
		fmt.Printf("# Projects step failed. Error: %s\n", err.Error())
		os.Exit(3)
	}

	// 5-app-infra
	msg.PrintStageMsg("Deploying 5-app-infra stage")
	io := stages.GetInfraPipelineOutputs(t, conf.CheckoutPath, "bu1-example-app")
	io.RemoteStateBucket = bo.RemoteStateBucketProjects

	msg.PrintBuildMsg(io.InfraPipeProj, io.DefaultRegion, conf.DisablePrompt)

	err = s.RunStep("bu1-example-app", func() error {
		return stages.DeployExampleAppStage(t, s, globalTFVars, io, conf)
	})
	if err != nil {
		fmt.Printf("# Example app step failed. Error: %s\n", err.Error())
		os.Exit(3)
	}
}
