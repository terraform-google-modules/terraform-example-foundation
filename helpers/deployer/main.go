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
	"strings"
	gotest "testing"
	"time"

	"github.com/mitchellh/go-testing-interface"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/deployer/gcp"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/deployer/stages"
	"github.com/terraform-google-modules/terraform-example-foundation/helpers/deployer/steps"
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
	flag.StringVar(&c.resetStep, "reset_step", "", "Name of a `step` to be reset.")
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

	//  only enable serivices if they are not already enabled
	if globalTFVars.HasValidatorProj() {
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
		s.ResetStep(cfg.resetStep)
		return
	}
}
