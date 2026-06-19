// Copyright 2026 Google LLC
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
	"errors"
	"fmt"
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
func ValidateIAMPermissions(p IAMValidateParams, verbose bool) error {
	if !isValidOrgID(p.OrgID) {
		return fmt.Errorf("invalid or missing org_id %q (expected numeric organization id)", p.OrgID)
	}

	folderID, checkFolder := resolveParentFolder(p)
	if p.ParentFolder != nil {
		pf := strings.TrimSpace(*p.ParentFolder)
		if pf != "" && pf != iamReplaceME && !checkFolder {
			return fmt.Errorf("invalid parent_folder %q (expected numeric folder id)", pf)
		}
	}

	if !isValidBillingAccount(p.BillingAccount) {
		return fmt.Errorf("invalid or missing billing_account %q (expected format XXXXXX-XXXXXX-XXXXXX)", p.BillingAccount)
	}

	ctx := context.Background()

	perms, err := loadRequiredPermissionsCore(p)
	if err != nil {
		return fmt.Errorf("IAM permissions validation failed: %w", err)
	}

	if len(perms.Skipped) > 0 {
		fmt.Printf("# note: skipped %d permissions not valid for org TestIamPermissions (validated via other checks): %s\n", len(perms.Skipped), strings.Join(perms.Skipped, ", "))
	}

	orgRes := "organizations/" + p.OrgID
	if err := checkOrgPermissions(ctx, orgRes, perms.Org, verbose); err != nil {
		return err
	}

	if checkFolder {
		folderRes := "folders/" + folderID
		if err := checkResourcePermissions(ctx, "FOLDER-PROJECTS", folderRes, perms.ProjectParent, verbose); err != nil {
			return err
		}
		if err := checkFolderPermissions(ctx, folderRes, perms.Folder, verbose); err != nil {
			return err
		}
	} else {
		if err := checkResourcePermissions(ctx, "ORG-PROJECTS", orgRes, perms.ProjectParent, verbose); err != nil {
			return err
		}
	}

	if err := checkBillingPermissions(ctx, "billingAccounts/"+p.BillingAccount, perms.Billing, verbose); err != nil {
		return err
	}

	return nil
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
	OrgPermissions     []string `yaml:"orgPermissions"`
	FolderPermissions  []string `yaml:"folderPermissions"`
	BillingPermissions []string `yaml:"billingPermissions"`
	// Items supports the legacy list format; entries are merged by field name (order-independent).
	Items []permissionsYAMLItem `yaml:"items,omitempty"`
}

type permissionsYAMLItem struct {
	OrgPermissions     []string `yaml:"orgPermissions,omitempty"`
	FolderPermissions  []string `yaml:"folderPermissions,omitempty"`
	BillingPermissions []string `yaml:"billingPermissions,omitempty"`
}

// normalize merges legacy items[] entries into the top-level permission lists.
func (c *permissionsYAML) normalize() {
	for _, item := range c.Items {
		c.OrgPermissions = append(c.OrgPermissions, item.OrgPermissions...)
		c.FolderPermissions = append(c.FolderPermissions, item.FolderPermissions...)
		c.BillingPermissions = append(c.BillingPermissions, item.BillingPermissions...)
	}
}

// RequiredPermissions groups the permission lists loaded from YAML.
type RequiredPermissions struct {
	Org           []string
	ProjectParent []string
	Folder        []string
	Billing       []string
	Skipped       []string
}

// loadRequiredPermissionsCore loads org / project-parent / folder / billing permission lists from YAML.
func loadRequiredPermissionsCore(p IAMValidateParams) (*RequiredPermissions, error) {
	path, err := resolvePermissionsYAMLPath(p)
	if err != nil {
		return nil, fmt.Errorf("failed to resolve permissions path: %w", err)
	}

	data, readErr := os.ReadFile(path)
	if readErr != nil {
		if errors.Is(readErr, os.ErrNotExist) {
			return nil, fmt.Errorf("permissions yaml file not found at %q", path)
		}
		return nil, fmt.Errorf("failed to read permissions yaml at %q: %w", path, readErr)
	}

	var cfg permissionsYAML
	if unmarshalErr := yaml.Unmarshal(data, &cfg); unmarshalErr != nil {
		return nil, fmt.Errorf("failed to parse permissions yaml at %q: %w", path, unmarshalErr)
	}
	cfg.normalize()

	// Validations using the original struct slices
	if len(cfg.FolderPermissions) == 0 {
		return nil, fmt.Errorf("permissions yaml at %q: folderPermissions must not be empty", path)
	}
	if len(cfg.BillingPermissions) == 0 {
		return nil, fmt.Errorf("permissions yaml at %q: billingPermissions must not be empty", path)
	}

	var projectParentPerms []string
	var orgPerms []string
	var skipped []string

	for _, perm := range cfg.OrgPermissions {
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
		return nil, fmt.Errorf("permissions yaml at %q: orgPermissions must include at least one org-scoped permission", path)
	}
	if len(projectParentPerms) == 0 {
		return nil, fmt.Errorf("permissions yaml at %q: orgPermissions must include resourcemanager.projects.* permissions", path)
	}

	sort.Strings(skipped)

	return &RequiredPermissions{
		Org:           orgPerms,
		ProjectParent: projectParentPerms,
		Folder:        cfg.FolderPermissions,
		Billing:       cfg.BillingPermissions,
		Skipped:       skipped,
	}, nil
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

	path := filepath.Join(p.FoundationCodePath, "helpers", "foundation-deployer", "examples", "iam", "default-permissions.yaml")
	absPath, err := filepath.Abs(path)
	if err != nil {
		return "", fmt.Errorf("failed to resolve bundled permissions yaml path: %w", err)
	}
	return absPath, nil
}

func checkResourcePermissions(ctx context.Context, scope, resource string, permissions []string, verbose bool) error {
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
			return fmt.Errorf("error creating folders client: %w", cErr)
		}
		defer func() {
			if closeErr := client.Close(); closeErr != nil {
				fmt.Fprintf(os.Stderr, "error closing folders client: %s\n", closeErr)
			}
		}()
		resp, err = client.TestIamPermissions(ctx, req)
	case strings.HasPrefix(resource, "organizations/"):
		client, cErr := resourcemanager.NewOrganizationsClient(ctx)
		if cErr != nil {
			return fmt.Errorf("error creating organizations client: %w", cErr)
		}
		defer func() {
			if closeErr := client.Close(); closeErr != nil {
				fmt.Fprintf(os.Stderr, "error closing organizations client: %s\n", closeErr)
			}
		}()
		resp, err = client.TestIamPermissions(ctx, req)
	default:
		return fmt.Errorf("unsupported resource for IAM check: %s", resource)
	}

	if err != nil {
		return fmt.Errorf("error checking permissions for %s: %w", resource, err)
	}
	printPermissions(scope, resource, permissions, resp.Permissions, verbose)
	return nil
}

func checkOrgPermissions(ctx context.Context, resource string, permissions []string, verbose bool) error {
	client, err := resourcemanager.NewOrganizationsClient(ctx)
	if err != nil {
		return fmt.Errorf("error creating org client: %w", err)
	}
	defer func() {
		if closeErr := client.Close(); closeErr != nil {
			fmt.Fprintf(os.Stderr, "error closing org client: %s\n", closeErr)
		}
	}()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		return fmt.Errorf("error checking org permissions for %s: %w", resource, err)
	}
	printPermissions("ORG", resource, permissions, resp.Permissions, verbose)
	return nil
}

func checkFolderPermissions(ctx context.Context, resource string, permissions []string, verbose bool) error {
	client, err := resourcemanager.NewFoldersClient(ctx)
	if err != nil {
		return fmt.Errorf("error creating folder client: %w", err)
	}
	defer func() {
		if closeErr := client.Close(); closeErr != nil {
			fmt.Fprintf(os.Stderr, "error closing folder client: %s\n", closeErr)
		}
	}()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		return fmt.Errorf("error checking folder permissions for %s: %w", resource, err)
	}
	printPermissions("FOLDER", resource, permissions, resp.Permissions, verbose)
	return nil
}

func checkBillingPermissions(ctx context.Context, resource string, permissions []string, verbose bool) error {
	client, err := billing.NewCloudBillingClient(ctx)
	if err != nil {
		return fmt.Errorf("error creating billing client: %w", err)
	}
	defer func() {
		if closeErr := client.Close(); closeErr != nil {
			fmt.Fprintf(os.Stderr, "error closing billing client: %s\n", closeErr)
		}
	}()

	resp, err := client.TestIamPermissions(ctx, &iampb.TestIamPermissionsRequest{
		Resource:    resource,
		Permissions: permissions,
	})
	if err != nil {
		return fmt.Errorf("error checking billing permissions for %s: %w", resource, err)
	}
	printPermissions("BILLING", resource, permissions, resp.Permissions, verbose)
	return nil
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
