package stages

import (
	"context"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strings"

	billing "cloud.google.com/go/billing/apiv1"
	iampb "cloud.google.com/go/iam/apiv1/iampb"
	resourcemanager "cloud.google.com/go/resourcemanager/apiv3"
	"gopkg.in/yaml.v3"
)

// validateIamPermissions keeps backwards-compat behavior for foundation-deployer -validate.
func validateIamPermissions(g GlobalTFVars) {
	ValidateIAMPermissions(g, false)
}

// ValidateIAMPermissions runs "TestIamPermissions" checks (similar to scripts/go-validate).
// It prints missing permissions for the currently authenticated principal (ADC).
//
// If verbose is true, it also prints the full list of allowed permissions returned by the API.
func ValidateIAMPermissions(g GlobalTFVars, verbose bool) {
	if g.OrgID == "" || g.OrgID == replaceME {
		return
	}

	ctx := context.Background()

	orgPerms, projectParentPerms, folderPerms, billingPerms := loadRequiredPermissions(g)

	orgRes := "organizations/" + g.OrgID
	checkOrgPermissions(ctx, orgRes, orgPerms, verbose)

	// Projects are created either under a parent folder (if set) or directly under the org.
	// Validate "projects.*" permissions on the effective parent resource to avoid false negatives.
	projectParentRes := orgRes
	projectParentScope := "ORG-PROJECTS"
	if g.ParentFolder != nil && *g.ParentFolder != "" && *g.ParentFolder != replaceME {
		projectParentRes = "folders/" + *g.ParentFolder
		projectParentScope = "FOLDER-PROJECTS"
	}
	checkResourcePermissions(ctx, projectParentScope, projectParentRes, projectParentPerms, verbose)

	if g.ParentFolder != nil && *g.ParentFolder != "" && *g.ParentFolder != replaceME {
		folderRes := "folders/" + *g.ParentFolder
		checkFolderPermissions(ctx, folderRes, folderPerms, verbose)
	}

	if g.BillingAccount != "" && g.BillingAccount != replaceME {
		billingRes := "billingAccounts/" + g.BillingAccount
		checkBillingPermissions(ctx, billingRes, billingPerms, verbose)
	}
}

func defaultOrgPermissions() []string {
	// Mirrors scripts/go-validate/permissions.yaml (orgPermissions) excluding project-parent perms.
	return []string{
		"accesscontextmanager.policies.create",
		"accesscontextmanager.policies.get",
		"accesscontextmanager.policies.getIamPolicy",
		"accesscontextmanager.policies.list",
		"accesscontextmanager.policies.setIamPolicy",
		"iam.serviceAccounts.getAccessToken",
		"resourcemanager.organizations.get",
		"resourcemanager.organizations.getIamPolicy",
		"resourcemanager.organizations.setIamPolicy",
		"serviceusage.services.list",
		"serviceusage.services.use",
	}
}

func defaultProjectParentPermissions() []string {
	// These permissions can be granted at org or folder level. We check them on the effective parent.
	return []string{
		"resourcemanager.projects.create",
		"resourcemanager.projects.delete",
		"resourcemanager.projects.get",
		"resourcemanager.projects.getIamPolicy",
		"resourcemanager.projects.list",
		"resourcemanager.projects.setIamPolicy",
	}
}

func defaultFolderPermissions() []string {
	return []string{
		"resourcemanager.folders.get",
		"resourcemanager.folders.create",
		"resourcemanager.folders.delete",
		"resourcemanager.folders.getIamPolicy",
		"resourcemanager.folders.setIamPolicy",
	}
}

func defaultBillingPermissions() []string {
	return []string{
		"billing.accounts.get",
		"billing.accounts.getIamPolicy",
		"billing.resourceAssociations.create",
	}
}

type permissionsYAML struct {
	Items []struct {
		OrgPermissions     []string `yaml:"orgPermissions"`
		FolderPermissions  []string `yaml:"folderPermissions"`
		BillingPermissions []string `yaml:"billingPermissions"`
	} `yaml:"items"`
}

func loadRequiredPermissions(g GlobalTFVars) (orgPerms, projectParentPerms, folderPerms, billingPerms []string) {
	orgPerms, projectParentPerms, folderPerms, billingPerms, skipped, err := loadRequiredPermissionsCore(g)
	if err != nil {
		log.Printf("# warning: %v\n", err)
	}
	if len(skipped) > 0 {
		log.Printf("# note: skipped %d permissions not valid for org TestIamPermissions (validated via other checks): %s\n", len(skipped), strings.Join(skipped, ", "))
	}
	return orgPerms, projectParentPerms, folderPerms, billingPerms
}

// loadRequiredPermissionsCore resolves org / project-parent / folder / billing permission lists.
// On YAML read/parse errors it returns the default lists and a non-nil err (caller may log).
// skipped lists permissions removed from org-level TestIamPermissions (SCC notification / tag keys).
func loadRequiredPermissionsCore(g GlobalTFVars) (orgPerms, projectParentPerms, folderPerms, billingPerms, skipped []string, err error) {
	orgPerms = defaultOrgPermissions()
	projectParentPerms = defaultProjectParentPermissions()
	folderPerms = defaultFolderPermissions()
	billingPerms = defaultBillingPermissions()

	if g.IAMPermissionsYAMLPath == nil || strings.TrimSpace(*g.IAMPermissionsYAMLPath) == "" {
		return orgPerms, projectParentPerms, folderPerms, billingPerms, nil, nil
	}

	p := strings.TrimSpace(*g.IAMPermissionsYAMLPath)
	if !filepath.IsAbs(p) && g.FoundationCodePath != "" && g.FoundationCodePath != replaceME {
		p = filepath.Join(g.FoundationCodePath, p)
	}

	data, readErr := os.ReadFile(p)
	if readErr != nil {
		return orgPerms, projectParentPerms, folderPerms, billingPerms, nil, fmt.Errorf("failed to read iam permissions yaml at %q: %w", p, readErr)
	}

	var cfg permissionsYAML
	if unmarshalErr := yaml.Unmarshal(data, &cfg); unmarshalErr != nil {
		return orgPerms, projectParentPerms, folderPerms, billingPerms, nil, fmt.Errorf("failed to parse iam permissions yaml at %q: %w", p, unmarshalErr)
	}
	if len(cfg.Items) < 3 {
		return orgPerms, projectParentPerms, folderPerms, billingPerms, nil, fmt.Errorf("iam permissions yaml at %q: expected 3 items, got %d", p, len(cfg.Items))
	}

	orgAll := cfg.Items[0].OrgPermissions
	folderPerms = append([]string(nil), cfg.Items[1].FolderPermissions...)
	billingPerms = append([]string(nil), cfg.Items[2].BillingPermissions...)

	projectParentPerms = []string{}
	orgPerms = []string{}
	skipped = []string{}
	for _, perm := range orgAll {
		switch {
		case strings.HasPrefix(perm, "resourcemanager.projects."):
			projectParentPerms = append(projectParentPerms, perm)
		case strings.HasPrefix(perm, "securitycenter.notificationConfigs."),
			strings.HasPrefix(perm, "resourcemanager.tagKeys."):
			skipped = append(skipped, perm)
		default:
			orgPerms = append(orgPerms, perm)
		}
	}

	if len(projectParentPerms) == 0 {
		projectParentPerms = defaultProjectParentPermissions()
	}

	sort.Strings(skipped)
	return orgPerms, projectParentPerms, folderPerms, billingPerms, skipped, nil
}

func checkResourcePermissions(ctx context.Context, scope, resource string, permissions []string, verbose bool) {
	var (
		resp *iampb.TestIamPermissionsResponse
		err  error
	)

	req := &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	}

	switch {
	case strings.HasPrefix(resource, "folders/"):
		client, cErr := resourcemanager.NewFoldersClient(ctx)
		if cErr != nil {
			log.Printf("# error creating folders client: %v\n", cErr)
			return
		}
		defer client.Close()
		resp, err = client.TestIamPermissions(ctx, req)
	case strings.HasPrefix(resource, "organizations/"):
		client, cErr := resourcemanager.NewOrganizationsClient(ctx)
		if cErr != nil {
			log.Printf("# error creating organizations client: %v\n", cErr)
			return
		}
		defer client.Close()
		resp, err = client.TestIamPermissions(ctx, req)
	default:
		log.Printf("# unsupported resource for IAM check: %s\n", resource)
		return
	}
	if err != nil {
		log.Printf("# error checking permissions for %s: %v\n", resource, err)
		return
	}
	printPermissions(scope, resource, permissions, resp.Permissions, verbose)
}

func checkOrgPermissions(ctx context.Context, resource string, permissions []string, verbose bool) {
	client, err := resourcemanager.NewOrganizationsClient(ctx)
	if err != nil {
		log.Printf("# error creating org client: %v\n", err)
		return
	}
	defer client.Close()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		log.Printf("# error checking org permissions for %s: %v\n", resource, err)
		return
	}
	printPermissions("ORG", resource, permissions, resp.Permissions, verbose)
}

func checkFolderPermissions(ctx context.Context, resource string, permissions []string, verbose bool) {
	client, err := resourcemanager.NewFoldersClient(ctx)
	if err != nil {
		log.Printf("# error creating folder client: %v\n", err)
		return
	}
	defer client.Close()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		log.Printf("# error checking folder permissions for %s: %v\n", resource, err)
		return
	}
	printPermissions("FOLDER", resource, permissions, resp.Permissions, verbose)
}

func checkBillingPermissions(ctx context.Context, resource string, permissions []string, verbose bool) {
	client, err := billing.NewCloudBillingClient(ctx)
	if err != nil {
		log.Printf("# error creating billing client: %v\n", err)
		return
	}
	defer client.Close()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		log.Printf("# error checking billing permissions for %s: %v\n", resource, err)
		return
	}
	printPermissions("BILLING", resource, permissions, resp.Permissions, verbose)
}

func printPermissions(scope, resource string, requested, allowed []string, verbose bool) {
	sort.Strings(requested)
	sort.Strings(allowed)
	allowedSet := map[string]struct{}{}
	for _, p := range allowed {
		allowedSet[p] = struct{}{}
	}

	missing := make([]string, 0)
	for _, p := range requested {
		if _, ok := allowedSet[p]; !ok {
			missing = append(missing, p)
		}
	}

	fmt.Printf("\n# IAM permissions check (%s)\n", scope)
	fmt.Printf("# Resource: %s\n", resource)

	if verbose {
		fmt.Println("# Allowed permissions:")
		for _, p := range allowed {
			fmt.Printf("# - %s\n", p)
		}
	}

	if len(missing) == 0 {
		fmt.Println("# All required permissions are granted.")
		return
	}

	fmt.Println("# Missing permissions:")
	for _, p := range missing {
		fmt.Printf("# - %s\n", p)
	}
	fmt.Printf("# Tip: grant roles containing the missing permissions on %s.\n", scopeHint(scope))
}

func scopeHint(scope string) string {
	switch strings.ToUpper(scope) {
	case "ORG":
		return "the organization"
	case "FOLDER":
		return "the folder"
	case "BILLING":
		return "the billing account"
	default:
		return "the target resource"
	}
}

