package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"sort"

	billing "cloud.google.com/go/billing/apiv1"
	iampb "cloud.google.com/go/iam/apiv1/iampb"
	resourcemanager "cloud.google.com/go/resourcemanager/apiv3"
)

func main() {
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

	allowedMap := map[string]bool{}
	for _, p := range allowed {
		allowedMap[p] = true
	}

	fmt.Printf("\n========== %s ==========\n", scope)
	fmt.Printf("Resource: %s\n\n", resource)

	fmt.Println("Allowed permissions:")
	for _, p := range allowed {
		fmt.Printf(" ok %s\n", p)
	}

	fmt.Println("\nMissing permissions:")
	for _, p := range requested {
		if !allowedMap[p] {
			fmt.Printf(" no ok %s\n", p)
		}
	}
}

func orgPermissions() []string {
	return []string{
		"accesscontextmanager.policies.get",
		"accesscontextmanager.policies.getIamPolicy",
		"accesscontextmanager.policies.list",
		"resourcemanager.folders.get",
		"resourcemanager.organizations.get",
		"billing.accounts.get",
		"resourcemanager.projects.get",
		"orgpolicy.policy.set",
		"iam.serviceAccounts.getAccessToken",
	}
}

func folderPermissions() []string {
	return []string{
		"resourcemanager.folders.get",
		"resourcemanager.folders.create",
		"resourcemanager.folders.delete",
		"resourcemanager.folders.getIamPolicy",
		"resourcemanager.folders.setIamPolicy",
	}
}

func billingPermissions() []string {
	return []string{
		"billing.accounts.get",
		"billing.accounts.getIamPolicy",
		"billing.resourceAssociations.create",
	}
}
