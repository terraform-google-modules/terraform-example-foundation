# Change log — `foundation-deployer -validate` (IAM / TestIamPermissions)

This document describes the changes implemented so that `foundation-deployer -validate` can validate IAM permissions **in the same spirit as** `scripts/go-validate` (using `TestIamPermissions`), in addition to the validations that already existed.

## Goal

Add an IAM permission check for the currently authenticated principal (ADC — Application Default Credentials), producing a list of **missing permissions** per scope:

- Organization (`organizations/<ORG_ID>`)
- Folder (`folders/<FOLDER_ID>` when `parent_folder` is used)
- Billing account (`billingAccounts/<BILLING_ACCOUNT_ID>`)

This helps you quickly understand which IAM permissions are missing before attempting a deployment.

## Summary of changes

### 1) New IAM validator inside `foundation-deployer`

- **New file**: `helpers/foundation-deployer/stages/iam_validate.go`
- **Behavior change**: `stages.ValidateBasicFields()` now calls `validateIamPermissions(g)` at the end of `-validate` runs (because `ValidateBasicFields` is only executed in `-validate` mode).

#### Permissions source (YAML via `global.tfvars`)

A new optional variable was added to `global.tfvars` so `-validate` can load required permissions from a YAML file:

- `iam_permissions_yaml_path` (optional string)

Behavior:

- If `iam_permissions_yaml_path` is **not** provided: a **default** (backwards-compatible) permission set is used.
- If `iam_permissions_yaml_path` is provided: the validator reads `items[0..2]` from YAML:
  - `items[0].orgPermissions`
  - `items[1].folderPermissions`
  - `items[2].billingPermissions`

Notes:

- The path may point to a file **inside or outside** the repository (for example `Foundation/permissions.yaml`).
- With `iam_permissions_yaml_path` configured, you don’t need to run `scripts/go-validate` to get “missing permissions”, since `foundation-deployer` (and the dedicated CLI below) can use the YAML as the source of truth.

Files updated:

- `helpers/foundation-deployer/stages/data.go` (new `IAMPermissionsYAMLPath` field)
- `helpers/foundation-deployer/global.tfvars.example` (documents the new input)

#### How it works

`TestIamPermissions` is executed against the appropriate resource(s) and prints:

- `# IAM permissions check (ORG)` for `organizations/<org_id>`
- `# IAM permissions check (FOLDER)` for `folders/<parent_folder>` (when configured)
- `# IAM permissions check (BILLING)` for `billingAccounts/<billing_account>`

Additionally, we validate **project creation/management** permissions on the *effective* project parent:

- `FOLDER-PROJECTS` if `parent_folder` is set (checked on `folders/<parent_folder>`)
- `ORG-PROJECTS` otherwise (checked on `organizations/<org_id>`)

Motivation: avoid false negatives when projects are created under a folder (common when using `parent_folder`) and `resourcemanager.projects.*` permissions must be valid on the correct parent.

When `iam_permissions_yaml_path` is used, `foundation-deployer` also automatically splits:

- `resourcemanager.projects.*` permissions (found under YAML `orgPermissions`) to be tested on the effective project parent (org or folder), producing the `ORG-PROJECTS`/`FOLDER-PROJECTS` block.

#### Client selection fix (ORG vs FOLDER)

The implementation uses the correct Resource Manager v3 client for each resource type:

- `organizations/...` → `resourcemanager.NewOrganizationsClient`
- `folders/...` → `resourcemanager.NewFoldersClient`

This avoids errors such as:

> `invalid organization name` when trying to test a `folders/<id>` resource using the Organizations client.

## Output changes

When running:

```bash
foundation-deployer -tfvars_file /path/to/global.tfvars -validate
```

You will see blocks like:

- `# IAM permissions check (ORG)`
- `# IAM permissions check (FOLDER)` (when `parent_folder` is configured)
- `# IAM permissions check (BILLING)`
- `# IAM permissions check (FOLDER-PROJECTS)` or `# IAM permissions check (ORG-PROJECTS)`

Each block prints **missing permissions** (not roles). Fixing the gaps means granting **roles** that include those permissions on the correct resource (org/folder/billing).

## Build and run (Linux/WSL)

From `helpers/foundation-deployer`:

```bash
go mod tidy
go test ./...
go install .
```

Run:

```bash
"$(go env GOPATH)/bin/foundation-deployer" -tfvars_file "/path/to/global.tfvars" -validate
```

### Run only IAM validate (dedicated CLI)

A dedicated CLI command (similar to `scripts/go-validate`) was added:

```bash
cd helpers/foundation-deployer
go run ./cmd/iam-validate -tfvars_file "/path/to/global.tfvars"
```

Verbose mode (prints **Allowed** + **Missing**):

```bash
cd helpers/foundation-deployer
go run ./cmd/iam-validate -tfvars_file "/path/to/global.tfvars" -v
```

## Unit tests

YAML loading and permission routing are covered by table-style tests on `loadRequiredPermissionsCore` (package `stages`):

- **No `iam_permissions_yaml_path`**: returns built-in defaults; no error.
- **Valid YAML**: splits `resourcemanager.projects.*` to the project-parent list; moves `securitycenter.notificationConfigs.*` and `resourcemanager.tagKeys.*` to a `skipped` list (not sent to org-level `TestIamPermissions`).
- **YAML without `projects.*`**: project-parent list falls back to the default project permissions.
- **Relative `iam_permissions_yaml_path`**: resolved against `foundation_code_path` when the path is not absolute.
- **Missing file / invalid YAML / fewer than three `items` entries**: returns a non-nil error **and** the default permission lists (same behavior as production, which logs a warning and keeps validating with defaults).

Run only these tests:

```bash
cd helpers/foundation-deployer
go test ./stages/ -count=1 -v -run TestLoadRequiredPermissionsCore
```

## Known limitations

- **`TestIamPermissions` is resource-type aware**: requesting permissions that are not valid for a given resource type can lead to `InvalidArgument`. The validator therefore checks permissions only on the resource types where they are valid (`organizations/`, `folders/`, `billingAccounts/`), and it validates “resource existence” checks (e.g., SCC notification / TagKey existence) through the existing `gcloud ... list` logic where applicable.

## Files changed (list)

- `helpers/foundation-deployer/stages/iam_validate.go` (new)
- `helpers/foundation-deployer/stages/iam_validate_test.go` (unit tests for `loadRequiredPermissionsCore`)
- `helpers/foundation-deployer/stages/validate.go` (calls IAM validation)
- `helpers/foundation-deployer/stages/data.go` (new `iam_permissions_yaml_path` input)
- `helpers/foundation-deployer/global.tfvars.example` (documents the new input)
- `helpers/foundation-deployer/permissions.yaml.example` (sample permissions YAML)
- `helpers/foundation-deployer/cmd/iam-validate/main.go` (new dedicated CLI)

