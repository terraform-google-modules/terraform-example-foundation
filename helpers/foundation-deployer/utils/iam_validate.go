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

package utils

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

const iamReplaceME = "REPLACE_ME"

// IAMValidateParams holds tfvars fields used by IAM TestIamPermissions validation.
//
// IAM permissions validation (TestIamPermissions): the foundation-deployer -validate flag
// also validates that the currently authenticated principal (ADC) has the required IAM
// permissions on:
//   - organization (organizations/<ORG_ID>) — required
//   - folder (folders/<FOLDER_ID> from parent_folder) — required
//   - billing account (billingAccounts/<BILLING_ACCOUNT_ID>) — required
//
// Project-parent permissions (resourcemanager.projects.*) are checked on the parent folder.
//
// Run only this validation from the repo root:
//
//	cd helpers/foundation-deployer
//	go run ./cmd/iam-validate -tfvars_file <PATH TO 'global.tfvars' FILE>
//
// Verbose output (prints allowed + missing):
//
//	go run ./cmd/iam-validate -tfvars_file <PATH TO 'global.tfvars' FILE> -v
type IAMValidateParams struct {
	OrgID string
	// FoundationCodePath is used to locate the bundled permissions YAML when IAMPermissionsYAMLPath is unset.
	FoundationCodePath string
	// IAMPermissionsYAMLPath is an optional absolute path to a permissions YAML file.
	IAMPermissionsYAMLPath *string
	ParentFolder           *string
	BillingAccount         string
}

// ValidateIAMPermissions runs TestIamPermissions checks against organization, folder, and billing resources for the ADC principal.
// It prints missing permissions for the currently authenticated principal (ADC).
// When verbose is true, it also prints the full list of allowed permissions returned by the API.
//
// See [IAMValidateParams] for scope, YAML configuration, and how to invoke the standalone CLI.
func ValidateIAMPermissions(p IAMValidateParams, verbose bool) {
	if !isValidOrgID(p.OrgID) {
		log.Printf("# IAM permissions validation skipped: invalid or missing org_id %q (expected numeric organization id)\n", p.OrgID)
		return
	}

	folderID, checkFolder := resolveParentFolder(p)
	if !checkFolder {
		parentFolder := ""
		if p.ParentFolder != nil {
			parentFolder = strings.TrimSpace(*p.ParentFolder)
		}
		log.Printf("# IAM permissions validation skipped: invalid or missing parent_folder %q (expected numeric folder id)\n", parentFolder)
		return
	}

	if !isValidBillingAccount(p.BillingAccount) {
		log.Printf("# IAM permissions validation skipped: invalid or missing billing_account %q (expected format XXXXXX-XXXXXX-XXXXXX)\n", p.BillingAccount)
		return
	}

	ctx := context.Background()

	orgPerms, projectParentPerms, folderPerms, billingPerms, skipped, err := loadRequiredPermissionsCore(p)
	if err != nil {
		log.Printf("# IAM permissions validation failed: %v\n", err)
		return
	}
	if len(skipped) > 0 {
		log.Printf("# note: skipped %d permissions not valid for org TestIamPermissions (validated via other checks): %s\n", len(skipped), strings.Join(skipped, ", "))
	}

	orgRes := "organizations/" + p.OrgID
	checkOrgPermissions(ctx, orgRes, orgPerms, verbose)

	folderRes := "folders/" + folderID
	checkResourcePermissions(ctx, "FOLDER-PROJECTS", folderRes, projectParentPerms, verbose)
	checkFolderPermissions(ctx, folderRes, folderPerms, verbose)

	checkBillingPermissions(ctx, "billingAccounts/"+p.BillingAccount, billingPerms, verbose)
}

func isIAMPlaceholder(s string) bool {
	return strings.TrimSpace(s) == "" || strings.TrimSpace(s) == iamReplaceME
}

func isValidOrgID(orgID string) bool {
	if isIAMPlaceholder(orgID) {
		return false
	}
	return isNumericID(orgID)
}

func isValidFolderID(folderID string) bool {
	if isIAMPlaceholder(folderID) {
		return false
	}
	return isNumericID(folderID)
}

func isValidBillingAccount(billingAccount string) bool {
	if isIAMPlaceholder(billingAccount) {
		return false
	}
	parts := strings.Split(billingAccount, "-")
	if len(parts) != 3 {
		return false
	}
	for _, part := range parts {
		if len(part) != 6 || !isAlphanumericSegment(part) {
			return false
		}
	}
	return true
}

func isAlphanumericSegment(s string) bool {
	for _, r := range s {
		if (r < '0' || r > '9') && (r < 'A' || r > 'Z') && (r < 'a' || r > 'z') {
			return false
		}
	}
	return true
}

func isNumericID(s string) bool {
	if s == "" {
		return false
	}
	for _, r := range s {
		if r < '0' || r > '9' {
			return false
		}
	}
	return true
}

// resolveParentFolder returns a trimmed folder id and whether folder-scoped checks should run.
func resolveParentFolder(p IAMValidateParams) (folderID string, ok bool) {
	if p.ParentFolder == nil {
		return "", false
	}
	folderID = strings.TrimSpace(*p.ParentFolder)
	if !isValidFolderID(folderID) {
		return folderID, false
	}
	return folderID, true
}

type permissionsYAML struct {
	Items []struct {
		OrgPermissions     []string `yaml:"orgPermissions"`
		FolderPermissions  []string `yaml:"folderPermissions"`
		BillingPermissions []string `yaml:"billingPermissions"`
	} `yaml:"items"`
}

// loadRequiredPermissionsCore loads org / project-parent / folder / billing permission lists from YAML.
func loadRequiredPermissionsCore(p IAMValidateParams) (orgPerms, projectParentPerms, folderPerms, billingPerms, skipped []string, err error) {
	path, err := resolvePermissionsYAMLPath(p)
	if err != nil {
		return nil, nil, nil, nil, nil, err
	}

	if _, statErr := os.Stat(path); statErr != nil {
		if os.IsNotExist(statErr) {
			return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml file not found at %q", path)
		}
		return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml file at %q is not readable: %w", path, statErr)
	}

	data, readErr := os.ReadFile(path)
	if readErr != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to read permissions yaml at %q: %w", path, readErr)
	}

	var cfg permissionsYAML
	if unmarshalErr := yaml.Unmarshal(data, &cfg); unmarshalErr != nil {
		return nil, nil, nil, nil, nil, fmt.Errorf("failed to parse permissions yaml at %q: %w", path, unmarshalErr)
	}
	if len(cfg.Items) < 3 {
		return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml at %q: expected 3 items, got %d", path, len(cfg.Items))
	}

	orgAll := cfg.Items[0].OrgPermissions
	folderPerms = append([]string(nil), cfg.Items[1].FolderPermissions...)
	billingPerms = append([]string(nil), cfg.Items[2].BillingPermissions...)

	if len(folderPerms) == 0 {
		return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml at %q: folderPermissions must not be empty", path)
	}
	if len(billingPerms) == 0 {
		return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml at %q: billingPermissions must not be empty", path)
	}

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

	if len(orgPerms) == 0 {
		return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml at %q: orgPermissions must include at least one org-scoped permission", path)
	}
	if len(projectParentPerms) == 0 {
		return nil, nil, nil, nil, nil, fmt.Errorf("permissions yaml at %q: orgPermissions must include resourcemanager.projects.* permissions", path)
	}

	sort.Strings(skipped)
	return orgPerms, projectParentPerms, folderPerms, billingPerms, skipped, nil
}

func resolvePermissionsYAMLPath(p IAMValidateParams) (string, error) {
	if p.IAMPermissionsYAMLPath != nil {
		path := strings.TrimSpace(*p.IAMPermissionsYAMLPath)
		if path == "" {
			return "", fmt.Errorf("permissions yaml path is empty")
		}
		if !filepath.IsAbs(path) {
			return "", fmt.Errorf("permissions yaml path must be an absolute path, got %q", path)
		}
		return path, nil
	}

	if strings.TrimSpace(p.FoundationCodePath) == "" || p.FoundationCodePath == iamReplaceME {
		return "", fmt.Errorf("permissions yaml path is required: set -permissions_yaml or foundation_code_path in tfvars")
	}

	// the segments below are a fixed relative path inside the repository, not configurable via tfvars.
	path := filepath.Join(p.FoundationCodePath, "helpers", "foundation-deployer", "examples", "iam", "default-permissions.yaml")
	absPath, err := filepath.Abs(path)
	if err != nil {
		return "", fmt.Errorf("failed to resolve bundled permissions yaml path: %w", err)
	}
	return absPath, nil
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
