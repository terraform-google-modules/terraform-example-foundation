# Testing / Validation Guide (Permissions)

This document describes the **testing approaches used to discover and validate the IAM permissions** required to deploy the foundation (e.g., via `foundation-deploy`) using a **dedicated project + service account** and GitHub-based automation.

## Use case

- A new Google Cloud **project** was created to host deployment tooling.
- A dedicated **service account** was created and used to run the deployment from GitHub.
- During testing, missing permissions were identified and iteratively added until the deployment could proceed.

This guide captures the concrete validation methods so other teammates can reproduce the checks.

## Prerequisites

- `gcloud` installed and configured
- Access to:
  - the target **Organization**
  - the target **Folder(s)**
  - the target **Billing account**
- Required APIs enabled (at minimum):
  - **Cloud Resource Manager API**
  - **Cloud Billing API**

Enable APIs (example):

```bash
gcloud services enable cloudresourcemanager.googleapis.com cloudbilling.googleapis.com
```

## Authentication methods tested

The following authentication flows were exercised while validating permissions. Use whichever matches your environment (local vs CI).

> Important: never commit tokens or JSON keys to git.

### Git token (GitHub)

If your workflow requires a Git token:

```bash
export GIT_TOKEN="REDACTED"
```

### gcloud user / ADC login (interactive)

```bash
gcloud auth login --account "SERVICE_ACCOUNT_OR_USER"
gcloud auth application-default login --account "SERVICE_ACCOUNT_OR_USER"
gcloud config set account "SERVICE_ACCOUNT_OR_USER"
```

### Service account key (non-interactive)

If using a JSON key locally (or in a controlled environment):

```bash
gcloud auth activate-service-account "SERVICE_ACCOUNT_EMAIL" --key-file="path/to/key.json"
```

## Granting billing permissions to the service account (example)

To allow the service account to interact with a billing account, bind the appropriate role on the billing account resource.

Example command used during testing:

```bash
gcloud beta billing accounts add-iam-policy-binding "BILLING_ACCOUNT_ID" \
  --member="serviceAccount:SERVICE_ACCOUNT_EMAIL" \
  --role="roles/billing.accounts.setIamPolicy"
```

One of the key permissions validated for billing association was:

- `billing.resourceAssociations.create`

## Testing approach A: REST calls to `testIamPermissions` (curl)

This method directly calls the Google Cloud APIs to validate which permissions the current identity has on a given resource.

### 1) Get an access token

```bash
ACCESS_TOKEN="$(gcloud auth print-access-token)"
```

If you need an API key for your environment, set it as `API_KEY` (do not share it publicly):

```bash
API_KEY="REDACTED"
```

### 2) Organization permission check (example)

```bash
curl --request POST \
  "https://cloudresourcemanager.googleapis.com/v3/organizations/ORG_ID:testIamPermissions?alt=json&prettyPrint=true&key=${API_KEY}" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data '{
    "permissions": [
      "accesscontextmanager.policies.get",
      "accesscontextmanager.policies.getIamPolicy",
      "accesscontextmanager.policies.list",
      "resourcemanager.folders.get",
      "resourcemanager.organizations.get",
      "billing.accounts.get",
      "resourcemanager.projects.get",
      "orgpolicy.policy.set",
      "iam.serviceAccounts.getAccessToken"
    ]
  }' \
  --compressed
```

### 3) Folder permission check (example)

```bash
curl --request POST \
  "https://cloudresourcemanager.googleapis.com/v3/folders/FOLDER_ID:testIamPermissions?alt=json&prettyPrint=true&key=${API_KEY}" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data '{
    "permissions": [
      "resourcemanager.folders.get",
      "resourcemanager.folders.create",
      "resourcemanager.folders.delete",
      "resourcemanager.folders.getIamPolicy",
      "resourcemanager.folders.setIamPolicy"
    ]
  }' \
  --compressed
```

### 4) Billing account permission check (example)

```bash
curl --request POST \
  "https://cloudbilling.googleapis.com/v1/billingAccounts/BILLING_ACCOUNT_ID:testIamPermissions?alt=json&prettyPrint=true&key=${API_KEY}" \
  --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Accept: application/json" \
  --header "Content-Type: application/json" \
  --data '{
    "permissions": [
      "billing.accounts.get",
      "billing.accounts.getIamPolicy",
      "billing.resourceAssociations.create"
    ]
  }' \
  --compressed
```

### How to interpret results

- The response includes a `permissions` array with the permissions the identity **actually has** on that resource.
- Any permission you requested but that is **not returned** is **missing** and must be granted (typically via a role binding on the relevant resource).

## Testing approach B: Use the `go-validate` helper

This repository includes a small Go program that automates the same `TestIamPermissions` checks and compares them to the required permissions in `permissions.yaml`.

From `scripts/go-validate/`:

```bash
go run . --org ORG_ID --folder FOLDER_ID --billing BILLING_ACCOUNT_ID
```

Verbose output:

```bash
go run . -v --org ORG_ID --folder FOLDER_ID --billing BILLING_ACCOUNT_ID
```

## Suggested workflow for teammates

- **Step 1**: Authenticate as the same identity your GitHub workflow will use (preferably Workload Identity Federation; if not available, use a controlled service account key for local reproduction).
- **Step 2**: Enable the required APIs (Resource Manager + Billing at minimum).
- **Step 3**: Run **Approach B (`go-validate`)** to get a quick “missing permissions” list.
- **Step 4**: For any surprising gaps, confirm with **Approach A (curl)** to validate the API-level truth.
- **Step 5**: Add the smallest role bindings necessary (principle of least privilege), re-run validation, then retry the deployment.
