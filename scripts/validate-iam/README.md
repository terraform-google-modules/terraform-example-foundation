# validate-iam (Go)

Validates the **effective IAM roles** of a deploy principal for the `0-bootstrap` prerequisites, including roles granted **via Google Groups and inheritance**.

This is intended to complement `scripts/validate-requirements.sh`, which only checks direct bindings.

## Why this exists (limitations of `validate-requirements.sh`)

The `0-bootstrap` docs note that `scripts/validate-requirements.sh` **cannot validate roles inherited via Google Groups**.
In practice it checks direct bindings by filtering IAM policies with `bindings.members:<user>`, which will not match:

- `group:...` bindings (user gets access via group membership)
- some “effective access” cases where policies are inherited and expanded through analysis tools

This `validate-iam` tool fills that gap by using **Policy Analyzer / Cloud Asset Inventory** and (when needed) **Cloud Billing** + **Cloud Identity** APIs.

## Prerequisites

- Go installed
- Application Default Credentials (ADC) configured:

```bash
gcloud auth application-default login
```

### Quota project (required for local user ADC)

When authenticating using **local user ADC**, Google APIs require a **quota project** to be set for billing/quota attribution.

```bash
gcloud auth application-default set-quota-project <QUOTA_PROJECT_ID>
```

### Enable required APIs (on the quota project)

Enable the APIs used by this tool on the quota project:

```bash
gcloud services enable cloudasset.googleapis.com --project <QUOTA_PROJECT_ID>
gcloud services enable cloudbilling.googleapis.com --project <QUOTA_PROJECT_ID>
gcloud services enable cloudidentity.googleapis.com --project <QUOTA_PROJECT_ID>
```

If you enable APIs and still get `SERVICE_DISABLED`, wait a few minutes and retry (propagation delay).

### IAM permissions needed

- **Org analysis (Cloud Asset Inventory)**: caller needs permission to run IAM policy analysis on the org scope (for example `roles/cloudasset.viewer` on the organization, or equivalent permissions such as `cloudasset.assets.analyzeIamPolicy`).
- **Billing fallback (Cloud Billing)**: caller must be able to call `billingAccounts.getIamPolicy` on the billing account.
- **Group expansion (Cloud Identity)**: caller typically needs permission to **read group membership** (Cloud Identity / Workspace group reader roles). Without it, you may see `403`/`forbidden` errors in `nonCriticalErrors`. This does not necessarily fail the validation if another accessible group already proves membership.

## Repo note: `go.work`

This repository has a `go.work` at the root. If you run from `scripts/validate-iam` and Go complains that the module is not in the workspace, you have two options:

- Add this module to the workspace (recommended):

```bash
cd <REPO_ROOT>
go work use ./scripts/validate-iam
```

- Or disable workspace just for this command:

```bash
cd scripts/validate-iam
GOWORK=off go run . <flags...>
```

## Usage

From repo root:

```bash
cd scripts/validate-iam
go run . -org 1234567890 -billing 012345-567890-ABCDEF -principal user:me@company.com -quota-project <QUOTA_PROJECT_ID>
```

If billing analysis returns `NotFound`, you can try providing a different scope for billing (project scope is often the easiest):

```bash
go run . -org 1234567890 -billing 012345-567890-ABCDEF -principal user:me@company.com -quota-project <QUOTA_PROJECT_ID> -billing-scope projects/<QUOTA_PROJECT_ID>
```

### Output modes

JSON output:

```bash
go run . -org 1234567890 -billing 012345-567890-ABCDEF -principal user:me@company.com -json
```

Verbose/explain output (can be noisy):

```bash
go run . -org 1234567890 -billing 012345-567890-ABCDEF -principal user:me@company.com -explain
```

## What the tool checks (and how)

### Organization roles (effective)

The org check uses **Cloud Asset Inventory** `AnalyzeIamPolicy` against:

- scope: `organizations/<ORG_ID>` (default; overridable via `-org-scope`)
- resource: `//cloudresourcemanager.googleapis.com/organizations/<ORG_ID>`
- identity: your `-principal`
- access selector: required roles

This surfaces **effective roles** including those granted via Google Groups / inheritance.

#### Conditional roles

You may see a role marked as `conditional:true` with evidence like `condition_eval=CONDITIONAL`.
That means the role is granted via an IAM binding with a condition and the analyzer could not fully evaluate it with the provided context.
It is still commonly “good enough” to proceed, but you should review the condition if you expect unconditional access.

### Billing roles (effective)

Billing accounts are tricky because Cloud Asset analysis can fail to “find” billing accounts as analyzable resource nodes in some scopes.
The tool uses a layered strategy:

1. **Cloud Asset `AnalyzeIamPolicy`** on the billing full resource name (best case).
2. If Cloud Asset returns `NotFound`, fallback to **Cloud Billing API** `billingAccounts.getIamPolicy`:
   - validates **direct `user:` bindings** for required roles
   - detects `group:` bindings and records an informational warning
3. If direct bindings are missing (common) and the billing policy uses `group:`:
   - tries a **Cloud Asset identity+access** query (no `resource_selector`) and filters results down to the billing account
   - if billing is still not satisfied, uses **Cloud Identity** `groups.memberships.checkTransitiveMembership` to confirm
     whether the user is a (direct or transitive) member of each `group:` principal that grants the required billing role.

This is how the tool can prove cases like: “user has `roles/billing.admin` because they are a member of `group:billing-admins@example.com`”.

## Flags

- `-org` (required): organization numeric ID
- `-billing` (required): billing account ID (e.g. `012345-567890-ABCDEF`)
- `-principal` (required): IAM principal (e.g. `user:me@domain.com`)
- `-quota-project` (recommended): quota project ID for ADC user credentials
- `-org-scope`: Cloud Asset scope for org analysis (default `organizations/<org>`)
- `-billing-scope`: Cloud Asset scope for billing analysis (default same as org-scope)
- `-org-roles`: override org roles (CSV)
- `-billing-roles`: override billing roles (CSV)
- `-json`: JSON output
- `-explain`: include extra evidence details (can be verbose/slow)
- `-timeout`: execution timeout per analysis call

## Troubleshooting

- **`Your application is authenticating by using local Application Default Credentials... requires a quota project`**
  - Run `gcloud auth application-default set-quota-project <QUOTA_PROJECT_ID>` or pass `-quota-project`.
- **`SERVICE_DISABLED`**
  - Enable the API shown in the error (`cloudasset.googleapis.com`, `cloudbilling.googleapis.com`, `cloudidentity.googleapis.com`) on the quota project.
- **Billing shows `group:` bindings but still `present:false`**
  - Ensure `cloudidentity.googleapis.com` is enabled and the caller has permission to read group membership; otherwise group membership cannot be confirmed.

## Default required roles

- **Organization**:
  - `roles/resourcemanager.organizationAdmin`
  - `roles/orgpolicy.policyAdmin`
  - `roles/resourcemanager.projectCreator`
  - `roles/resourcemanager.folderCreator`
  - `roles/securitycenter.admin`
- **Billing account**:
  - `roles/billing.admin`

You can override these with `-org-roles` and `-billing-roles` (comma-separated).

