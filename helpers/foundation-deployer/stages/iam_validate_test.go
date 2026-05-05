package stages

import (
	"os"
	"path/filepath"
	"slices"
	"testing"
)

func strPtr(s string) *string { return &s }

func TestLoadRequiredPermissionsCore_noYAMLPathUsesDefaults(t *testing.T) {
	g := GlobalTFVars{
		OrgID:                "123",
		FoundationCodePath:   "/tmp",
		IAMPermissionsYAMLPath: nil,
	}
	org, proj, folder, bill, skipped, err := loadRequiredPermissionsCore(g)
	if err != nil {
		t.Fatalf("err: %v", err)
	}
	if len(skipped) != 0 {
		t.Fatalf("skipped: %v", skipped)
	}
	if !slices.Equal(org, defaultOrgPermissions()) {
		t.Fatalf("org mismatch\ngot:  %v\nwant: %v", org, defaultOrgPermissions())
	}
	if !slices.Equal(proj, defaultProjectParentPermissions()) {
		t.Fatalf("project parent mismatch\ngot:  %v\nwant: %v", proj, defaultProjectParentPermissions())
	}
	if !slices.Equal(folder, defaultFolderPermissions()) {
		t.Fatalf("folder mismatch\ngot:  %v\nwant: %v", folder, defaultFolderPermissions())
	}
	if !slices.Equal(bill, defaultBillingPermissions()) {
		t.Fatalf("billing mismatch\ngot:  %v\nwant: %v", bill, defaultBillingPermissions())
	}
}

func TestLoadRequiredPermissionsCore_splitsProjectsAndSkipsSCCAndTags(t *testing.T) {
	dir := t.TempDir()
	yamlPath := filepath.Join(dir, "permissions.yaml")
	content := `items:
  - orgPermissions:
      - resourcemanager.organizations.get
      - resourcemanager.projects.create
      - securitycenter.notificationConfigs.list
      - resourcemanager.tagKeys.get
  - folderPermissions:
      - resourcemanager.folders.get
  - billingPermissions:
      - billing.accounts.get
`
	if err := os.WriteFile(yamlPath, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}

	g := GlobalTFVars{
		OrgID:                "123",
		FoundationCodePath:   "/unused",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	org, proj, folder, bill, skipped, err := loadRequiredPermissionsCore(g)
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

func TestLoadRequiredPermissionsCore_emptyProjectsFallsBackToDefaults(t *testing.T) {
	dir := t.TempDir()
	yamlPath := filepath.Join(dir, "permissions.yaml")
	content := `items:
  - orgPermissions:
      - resourcemanager.organizations.get
  - folderPermissions:
      - resourcemanager.folders.get
  - billingPermissions:
      - billing.accounts.get
`
	if err := os.WriteFile(yamlPath, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}

	g := GlobalTFVars{
		OrgID:                "123",
		IAMPermissionsYAMLPath: strPtr(yamlPath),
	}
	_, proj, _, _, _, err := loadRequiredPermissionsCore(g)
	if err != nil {
		t.Fatalf("err: %v", err)
	}
	if !slices.Equal(proj, defaultProjectParentPermissions()) {
		t.Fatalf("project parent should default when YAML has no projects.*\ngot:  %v\nwant: %v", proj, defaultProjectParentPermissions())
	}
}

func TestLoadRequiredPermissionsCore_relativePathResolvedFromFoundationCodePath(t *testing.T) {
	base := t.TempDir()
	if err := os.MkdirAll(filepath.Join(base, "cfg"), 0o700); err != nil {
		t.Fatal(err)
	}
	rel := filepath.Join("cfg", "permissions.yaml")
	abs := filepath.Join(base, rel)
	content := `items:
  - orgPermissions:
      - serviceusage.services.use
  - folderPermissions:
      - resourcemanager.folders.create
  - billingPermissions:
      - billing.resourceAssociations.create
`
	if err := os.WriteFile(abs, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}

	g := GlobalTFVars{
		OrgID:                "123",
		FoundationCodePath:   base,
		IAMPermissionsYAMLPath: strPtr(rel),
	}
	org, _, folder, bill, _, err := loadRequiredPermissionsCore(g)
	if err != nil {
		t.Fatalf("err: %v", err)
	}
	if !slices.Equal(org, []string{"serviceusage.services.use"}) {
		t.Fatalf("org: %v", org)
	}
	if !slices.Equal(folder, []string{"resourcemanager.folders.create"}) {
		t.Fatalf("folder: %v", folder)
	}
	if !slices.Equal(bill, []string{"billing.resourceAssociations.create"}) {
		t.Fatalf("bill: %v", bill)
	}
}

func TestLoadRequiredPermissionsCore_missingFileReturnsErrorAndDefaults(t *testing.T) {
	g := GlobalTFVars{
		OrgID:                "123",
		IAMPermissionsYAMLPath: strPtr(filepath.Join(t.TempDir(), "nope.yaml")),
	}
	org, proj, folder, bill, skipped, err := loadRequiredPermissionsCore(g)
	if err == nil {
		t.Fatal("expected error")
	}
	if len(skipped) != 0 {
		t.Fatalf("skipped: %v", skipped)
	}
	if !slices.Equal(org, defaultOrgPermissions()) {
		t.Fatalf("org should remain defaults on error")
	}
	if !slices.Equal(proj, defaultProjectParentPermissions()) {
		t.Fatalf("proj should remain defaults on error")
	}
	if !slices.Equal(folder, defaultFolderPermissions()) {
		t.Fatalf("folder should remain defaults on error")
	}
	if !slices.Equal(bill, defaultBillingPermissions()) {
		t.Fatalf("billing should remain defaults on error")
	}
}

func TestLoadRequiredPermissionsCore_invalidYAMLReturnsError(t *testing.T) {
	dir := t.TempDir()
	p := filepath.Join(dir, "bad.yaml")
	if err := os.WriteFile(p, []byte("items: [\n"), 0o600); err != nil {
		t.Fatal(err)
	}
	g := GlobalTFVars{OrgID: "1", IAMPermissionsYAMLPath: strPtr(p)}
	_, _, _, _, _, err := loadRequiredPermissionsCore(g)
	if err == nil {
		t.Fatal("expected parse error")
	}
}

func TestLoadRequiredPermissionsCore_tooFewItemsReturnsError(t *testing.T) {
	dir := t.TempDir()
	p := filepath.Join(dir, "short.yaml")
	content := `items:
  - orgPermissions: []
`
	if err := os.WriteFile(p, []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}
	g := GlobalTFVars{OrgID: "1", IAMPermissionsYAMLPath: strPtr(p)}
	_, _, _, _, _, err := loadRequiredPermissionsCore(g)
	if err == nil {
		t.Fatal("expected format error")
	}
}
