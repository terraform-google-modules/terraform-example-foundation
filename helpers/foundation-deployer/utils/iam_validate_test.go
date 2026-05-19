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
	"os"
	"path/filepath"
	"slices"
	"strings"
	"testing"
)

func strPtr(s string) *string { return &s }

func writePermissionsYAML(t *testing.T, dir, name, content string) string {
	t.Helper()
	path := filepath.Join(dir, name)
	if err := os.WriteFile(path, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
	return path
}

func TestLoadRequiredPermissionsCore_splitsProjectsAndSkipsSCCAndTags(t *testing.T) {
	yamlPath := writePermissionsYAML(t, t.TempDir(), "permissions.yaml", `items:
  - orgPermissions:
      - resourcemanager.organizations.get
      - resourcemanager.projects.create
      - securitycenter.notificationConfigs.list
      - resourcemanager.tagKeys.get
  - folderPermissions:
      - resourcemanager.folders.get
  - billingPermissions:
      - billing.accounts.get
`)

	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	org, proj, folder, bill, skipped, err := loadRequiredPermissionsCore(p)
	if err != nil {
		t.Fatalf("err: %v", err)
	}

	wantOrg := []string{"resourcemanager.organizations.get"}
	if !slices.Equal(org, wantOrg) {
		t.Fatalf("org: got %v want %v", org, wantOrg)
	}
	wantProj := []string{"resourcemanager.projects.create"}
	if !slices.Equal(proj, wantProj) {
		t.Fatalf("proj: got %v want %v", proj, wantProj)
	}
	wantFolder := []string{"resourcemanager.folders.get"}
	if !slices.Equal(folder, wantFolder) {
		t.Fatalf("folder: got %v want %v", folder, wantFolder)
	}
	wantBill := []string{"billing.accounts.get"}
	if !slices.Equal(bill, wantBill) {
		t.Fatalf("billing: got %v want %v", bill, wantBill)
	}
	wantSkipped := []string{"resourcemanager.tagKeys.get", "securitycenter.notificationConfigs.list"}
	if !slices.Equal(skipped, wantSkipped) {
		t.Fatalf("skipped: got %v want %v", skipped, wantSkipped)
	}
}

func TestLoadRequiredPermissionsCore_emptyProjectsReturnsError(t *testing.T) {
	yamlPath := writePermissionsYAML(t, t.TempDir(), "permissions.yaml", `items:
  - orgPermissions:
      - resourcemanager.organizations.get
  - folderPermissions:
      - resourcemanager.folders.get
  - billingPermissions:
      - billing.accounts.get
`)

	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	_, _, _, _, _, err := loadRequiredPermissionsCore(p)
	if err == nil {
		t.Fatal("expected error when orgPermissions has no resourcemanager.projects.* permissions")
	}
}

func TestLoadRequiredPermissionsCore_noYAMLPathReturnsError(t *testing.T) {
	_, _, _, _, _, err := loadRequiredPermissionsCore(IAMValidateParams{OrgID: "123"})
	if err == nil {
		t.Fatal("expected error when permissions yaml path is not configured")
	}
}

func TestLoadRequiredPermissionsCore_relativeYAMLPathReturnsError(t *testing.T) {
	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr("cfg/permissions.yaml"),
	}
	_, _, _, _, _, err := loadRequiredPermissionsCore(p)
	if err == nil {
		t.Fatal("expected error for relative permissions yaml path")
	}
}

func TestLoadRequiredPermissionsCore_missingFileReturnsError(t *testing.T) {
	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(filepath.Join(t.TempDir(), "nope.yaml")),
	}
	_, _, _, _, _, err := loadRequiredPermissionsCore(p)
	if err == nil {
		t.Fatal("expected error")
	}
	if !strings.Contains(err.Error(), "not found") {
		t.Fatalf("unexpected error: %v", err)
	}
}

func TestLoadRequiredPermissionsCore_invalidYAMLReturnsError(t *testing.T) {
	pth := writePermissionsYAML(t, t.TempDir(), "bad.yaml", "items: [\n")
	p := IAMValidateParams{OrgID: "1", IAMPermissionsYAMLPath: strPtr(pth)}
	_, _, _, _, _, err := loadRequiredPermissionsCore(p)
	if err == nil {
		t.Fatal("expected parse error")
	}
}

func TestLoadRequiredPermissionsCore_tooFewItemsReturnsError(t *testing.T) {
	pth := writePermissionsYAML(t, t.TempDir(), "short.yaml", `items:
  - orgPermissions: []
`)
	p := IAMValidateParams{OrgID: "1", IAMPermissionsYAMLPath: strPtr(pth)}
	_, _, _, _, _, err := loadRequiredPermissionsCore(p)
	if err == nil {
		t.Fatal("expected format error")
	}
}

func TestResolvePermissionsYAMLPath_fromFoundationCodePath(t *testing.T) {
	dir := t.TempDir()
	bundled := filepath.Join(dir, "helpers", "foundation-deployer", "examples", "iam")
	if err := os.MkdirAll(bundled, 0o700); err != nil {
		t.Fatal(err)
	}
	yamlFile := filepath.Join(bundled, "default-permissions.yaml")
	if err := os.WriteFile(yamlFile, []byte("items:\n  - orgPermissions: []\n  - folderPermissions: []\n  - billingPermissions: []\n"), 0o600); err != nil {
		t.Fatal(err)
	}

	path, err := resolvePermissionsYAMLPath(IAMValidateParams{FoundationCodePath: dir})
	if err != nil {
		t.Fatalf("err: %v", err)
	}
	if !filepath.IsAbs(path) {
		t.Fatalf("expected absolute path, got %q", path)
	}
	if path != yamlFile {
		t.Fatalf("got %q want %q", path, yamlFile)
	}
}

func TestIsValidOrgID(t *testing.T) {
	if isValidOrgID("123456789012") != true {
		t.Fatal("expected valid org id")
	}
	if isValidOrgID("") || isValidOrgID("REPLACE_ME") || isValidOrgID("org-123") {
		t.Fatal("expected invalid org id")
	}
}

func TestIsValidFolderID(t *testing.T) {
	if isValidFolderID("987654321098") != true {
		t.Fatal("expected valid folder id")
	}
	if isValidFolderID("REPLACE_ME") || isValidFolderID("fldr-1") {
		t.Fatal("expected invalid folder id")
	}
}

func TestIsValidBillingAccount(t *testing.T) {
	if isValidBillingAccount("ABCDEF-123456-789ABC") != true {
		t.Fatal("expected valid billing account")
	}
	if isValidBillingAccount("REPLACE_ME") || isValidBillingAccount("invalid") {
		t.Fatal("expected invalid billing account")
	}
}

func TestResolveParentFolder(t *testing.T) {
	id, ok := resolveParentFolder(IAMValidateParams{ParentFolder: strPtr("987654321098")})
	if !ok || id != "987654321098" {
		t.Fatalf("got id=%q ok=%v", id, ok)
	}
	_, ok = resolveParentFolder(IAMValidateParams{ParentFolder: strPtr("REPLACE_ME")})
	if ok {
		t.Fatal("placeholder folder should not be used")
	}
	_, ok = resolveParentFolder(IAMValidateParams{})
	if ok {
		t.Fatal("nil parent folder should not be used")
	}
}
