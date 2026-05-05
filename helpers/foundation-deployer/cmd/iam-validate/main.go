package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/terraform-google-modules/terraform-example-foundation/helpers/foundation-deployer/stages"
)

func main() {
	var (
		tfvarsFile string
		verbose    bool
	)

	flag.StringVar(&tfvarsFile, "tfvars_file", "", "Full path to the Terraform .tfvars file with the configuration to be used.")
	flag.BoolVar(&verbose, "v", false, "show full output (allowed + missing permissions)")
	flag.Parse()

	if tfvarsFile == "" {
		fmt.Println("missing required flag: -tfvars_file")
		os.Exit(2)
	}

	globalTFVars, err := stages.ReadGlobalTFVars(tfvarsFile)
	if err != nil {
		fmt.Printf("# Failed to read GlobalTFVars file. Error: %s\n", err.Error())
		os.Exit(1)
	}

	stages.ValidateIAMPermissions(globalTFVars, verbose)
}

