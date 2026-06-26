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
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
)

func strPtr(s string) *string { return &s }

func writePermissionsYAML(t *testing.T, dir, name, content string) string {
	t.Helper()
	path := filepath.Join(dir, name)
	err := os.WriteFile(path, []byte(content), 0o600)
	assert.NoError(t, err)
	return path
}

func TestLoadRequiredPermissionsCore_splitsProjectsAndSkipsSCCAndTags(t *testing.T) {
	yamlPath := writePermissionsYAML(t, t.TempDir(), "permissions.yaml", `orgPermissions:
  - resourcemanager.organizations.get
  - resourcemanager.projects.create
  - securitycenter.notificationConfigs.list
  - resourcemanager.tagKeys.get
folderPermissions:
  - resourcemanager.folders.get
billingPermissions:
  - billing.accounts.get
`)

	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	perms, err := loadRequiredPermissionsCore(p)
	assert.NoError(t, err)
	assert.Equal(t, []string{"resourcemanager.organizations.get"}, perms.Org, "org permissions")
	assert.Equal(t, []string{"resourcemanager.projects.create"}, perms.ProjectParent, "project-parent permissions")
	assert.Equal(t, []string{"resourcemanager.folders.get"}, perms.Folder, "folder permissions")
	assert.Equal(t, []string{"billing.accounts.get"}, perms.Billing, "billing permissions")
	assert.Equal(t, []string{"resourcemanager.tagKeys.get", "securitycenter.notificationConfigs.list"}, perms.Skipped, "skipped permissions")
}

func TestLoadRequiredPermissionsCore_legacyItemsOrderIndependent(t *testing.T) {
	yamlPath := writePermissionsYAML(t, t.TempDir(), "permissions.yaml", `items:
  - billingPermissions:
      - billing.accounts.get
  - folderPermissions:
      - resourcemanager.folders.get
  - orgPermissions:
      - resourcemanager.organizations.get
      - resourcemanager.projects.create
`)

	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	perms, err := loadRequiredPermissionsCore(p)
	assert.NoError(t, err)
	assert.Equal(t, []string{"resourcemanager.organizations.get"}, perms.Org)
	assert.Equal(t, []string{"resourcemanager.projects.create"}, perms.ProjectParent)
	assert.Equal(t, []string{"resourcemanager.folders.get"}, perms.Folder)
	assert.Equal(t, []string{"billing.accounts.get"}, perms.Billing)
}

func TestLoadRequiredPermissionsCore_emptyProjectsReturnsError(t *testing.T) {
	yamlPath := writePermissionsYAML(t, t.TempDir(), "permissions.yaml", `orgPermissions:
  - resourcemanager.organizations.get
folderPermissions:
  - resourcemanager.folders.get
billingPermissions:
  - billing.accounts.get
`)

	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	_, err := loadRequiredPermissionsCore(p)
	assert.Error(t, err, "expected error when orgPermissions has no resourcemanager.projects.* permissions")
}

func TestLoadRequiredPermissionsCore_noYAMLPathReturnsError(t *testing.T) {
	_, err := loadRequiredPermissionsCore(IAMValidateParams{OrgID: "123"})
	assert.Error(t, err, "expected error when permissions yaml path is not configured")
}

func TestLoadRequiredPermissionsCore_relativeYAMLPathReturnsError(t *testing.T) {
	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr("cfg/permissions.yaml"),
	}
	_, err := loadRequiredPermissionsCore(p)
	assert.Error(t, err, "expected error for relative permissions yaml path")
}

func TestLoadRequiredPermissionsCore_missingFileReturnsError(t *testing.T) {
	p := IAMValidateParams{
		OrgID:                  "123",
		IAMPermissionsYAMLPath: strPtr(filepath.Join(t.TempDir(), "nope.yaml")),
	}
	_, err := loadRequiredPermissionsCore(p)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "not found")
}

func TestLoadRequiredPermissionsCore_invalidYAMLReturnsError(t *testing.T) {
	pth := writePermissionsYAML(t, t.TempDir(), "bad.yaml", "orgPermissions: [\n")
	p := IAMValidateParams{OrgID: "1", IAMPermissionsYAMLPath: strPtr(pth)}
	_, err := loadRequiredPermissionsCore(p)
	assert.Error(t, err, "expected parse error")
}

func TestLoadRequiredPermissionsCore_missingFolderPermissionsReturnsError(t *testing.T) {
	pth := writePermissionsYAML(t, t.TempDir(), "short.yaml", `orgPermissions:
  - resourcemanager.organizations.get
  - resourcemanager.projects.create
billingPermissions:
  - billing.accounts.get
`)
	p := IAMValidateParams{OrgID: "1", IAMPermissionsYAMLPath: strPtr(pth)}
	_, err := loadRequiredPermissionsCore(p)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "folderPermissions must not be empty")
}

func TestResolvePermissionsYAMLPath_fromFoundationCodePath(t *testing.T) {
	dir := t.TempDir()
	bundled := filepath.Join(dir, "helpers", "foundation-deployer", "examples", "iam")
	err := os.MkdirAll(bundled, 0o700)
	assert.NoError(t, err)
	yamlFile := filepath.Join(bundled, "default-permissions.yaml")
	err = os.WriteFile(yamlFile, []byte(`orgPermissions:
  - resourcemanager.organizations.get
  - resourcemanager.projects.create
folderPermissions:
  - resourcemanager.folders.get
billingPermissions:
  - billing.accounts.get
`), 0o600)
	assert.NoError(t, err)

	path, err := resolvePermissionsYAMLPath(IAMValidateParams{FoundationCodePath: dir})
	assert.NoError(t, err)
	assert.True(t, filepath.IsAbs(path), "resolved path should be absolute")
	assert.Equal(t, yamlFile, path, "resolved path should match bundled default-permissions.yaml")
}

func TestIsValidOrgID(t *testing.T) {
	assert.True(t, isValidOrgID("123456789012"), "numeric org id should be valid")
	assert.False(t, isValidOrgID(""), "empty org id should be invalid")
	assert.False(t, isValidOrgID("REPLACE_ME"), "placeholder org id should be invalid")
	assert.False(t, isValidOrgID("org-123"), "non-numeric org id should be invalid")
}

func TestIsValidFolderID(t *testing.T) {
	assert.True(t, isValidFolderID("987654321098"), "numeric folder id should be valid")
	assert.False(t, isValidFolderID("REPLACE_ME"), "placeholder folder id should be invalid")
	assert.False(t, isValidFolderID("fldr-1"), "non-numeric folder id should be invalid")
}

func TestIsValidBillingAccount(t *testing.T) {
	assert.True(t, isValidBillingAccount("ABCDEF-123456-789ABC"), "billing account should be valid")
	assert.False(t, isValidBillingAccount("REPLACE_ME"), "placeholder billing account should be invalid")
	assert.False(t, isValidBillingAccount("invalid"), "malformed billing account should be invalid")
}

func TestResolveParentFolder(t *testing.T) {
	id, ok := resolveParentFolder(IAMValidateParams{ParentFolder: strPtr("987654321098")})
	assert.True(t, ok, "numeric parent folder should resolve")
	assert.Equal(t, "987654321098", id, "folder id should match")

	_, ok = resolveParentFolder(IAMValidateParams{ParentFolder: strPtr("REPLACE_ME")})
	assert.False(t, ok, "placeholder folder should not be used")

	_, ok = resolveParentFolder(IAMValidateParams{})
	assert.False(t, ok, "nil parent folder should not be used")
}
