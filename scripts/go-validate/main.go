package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"sort"

	"gopkg.in/yaml.v3" //

	billing "cloud.google.com/go/billing/apiv1"
	iampb "cloud.google.com/go/iam/apiv1/iampb"
	resourcemanager "cloud.google.com/go/resourcemanager/apiv3"
)

var verbose bool

func main() {
	// Define a flag -v (nome, valor padrão, descrição)
	flag.BoolVar(&verbose, "v", false, "show full output")
	orgID := flag.String("org", "", "Organization ID")
	folderID := flag.String("folder", "", "Folder ID")
	billingID := flag.String("billing", "", "Billing Account ID")
	flag.Parse()

	ctx := context.Background()

	if *orgID != "" {
		checkOrg(ctx, "organizations/"+*orgID, orgPermissions())
	}

	if *folderID != "" {
		checkFolder(ctx, "folders/"+*folderID, folderPermissions())
	}

	if *billingID != "" {
		checkBilling(ctx, "billingAccounts/"+*billingID, billingPermissions())
	}
}

func checkOrg(ctx context.Context, resource string, permissions []string) {
	client, err := resourcemanager.NewOrganizationsClient(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		log.Printf("error checking org %s: %v\n", resource, err)
		return
	}

	printResult("ORG", resource, permissions, resp.Permissions)
}

func checkFolder(ctx context.Context, resource string, permissions []string) {
	client, err := resourcemanager.NewFoldersClient(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		log.Printf("error checking folder %s: %v\n", resource, err)
		return
	}

	printResult("FOLDER", resource, permissions, resp.Permissions)
}

func checkBilling(ctx context.Context, resource string, permissions []string) {
	client, err := billing.NewCloudBillingClient(ctx)
	if err != nil {
		log.Fatal(err)
	}
	defer client.Close()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		log.Printf("error checking billing %s: %v\n", resource, err)
		return
	}

	printResult("BILLING", resource, permissions, resp.Permissions)
}

func printResult(scope, resource string, requested, allowed []string) {

	sort.Strings(requested)
	sort.Strings(allowed)
	hasMissing := false
	allowedMap := map[string]bool{}
	for _, p := range allowed {
		allowedMap[p] = true
	}

	if !verbose {
		fmt.Printf("\n========== %s ==========\n", scope)
		fmt.Printf("Resource: %s\n", resource)
		for _, p := range requested {
			if !allowedMap[p] {
				fmt.Println("\n- Missing permissions:")
				hasMissing = true
				fmt.Printf("   - %s\n", p)
			}
		}
		if !hasMissing {
			fmt.Println("\n  All permissions are granted  \n")
		}
	} else {

		fmt.Printf("\n========== %s ==========\n", scope)
		fmt.Printf("Resource: %s\n\n", resource)

		fmt.Println("Allowed permissions:")
		for _, p := range allowed {
			fmt.Printf("  - %s\n", p)
		}

		for _, p := range requested {
			if !allowedMap[p] {
				fmt.Println("\nMissing permissions:")
				hasMissing = true
				fmt.Printf("  - %s\n", p)
			}
		}
		if !hasMissing {
			fmt.Println("\n  All permissions are granted  ")
		}
	}
}

type Config struct {
	Items []struct {
		OrgPermissions     []string `yaml:"orgPermissions"`
		FolderPermissions  []string `yaml:"folderPermissions"`
		BillingPermissions []string `yaml:"billingPermissions"`
	} `yaml:"items"`
}

func orgPermissions() []string {
	data, err := os.ReadFile("permissions.yaml")
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return nil
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		fmt.Printf("Error unmarshaling YAML: %v\n", err)
		return nil
	}

	if len(config.Items) > 0 {
		return config.Items[0].OrgPermissions
	}

	return []string{}
}

func folderPermissions() []string {
	data, err := os.ReadFile("permissions.yaml")
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return nil
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		fmt.Printf("Error unmarshaling YAML: %v\n", err)
		return nil
	}

	if len(config.Items) > 0 {
		return config.Items[1].FolderPermissions
	}

	return []string{}
}

func billingPermissions() []string {
	data, err := os.ReadFile("permissions.yaml")
	if err != nil {
		fmt.Printf("Error reading file: %v\n", err)
		return nil
	}

	var config Config
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		fmt.Printf("Error unmarshaling YAML: %v\n", err)
		return nil
	}

	if len(config.Items) > 0 {
		return config.Items[2].BillingPermissions
	}

	return []string{}
}
