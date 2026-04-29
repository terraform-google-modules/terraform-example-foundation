# go-validate

Small Go utility to **validate Google Cloud IAM permissions** for the currently authenticated principal against a target:

- **Organization** (`organizations/<ORG_ID>`)
- **Folder** (`folders/<FOLDER_ID>`)
- **Billing account** (`billingAccounts/<BILLING_ACCOUNT_ID>`)

It calls Google Cloud `TestIamPermissions` APIs and compares the returned (allowed) permissions with the required permissions defined in `permissions.yaml`.

## What it checks

The required permissions live in `permissions.yaml`:

- `items[0].orgPermissions`
- `items[1].folderPermissions`
- `items[2].billingPermissions`

## Prerequisites

- Go **1.25+**
- Application Default Credentials (ADC) available to the process (for example via `gcloud auth application-default login`, or a service account credential in CI)
- Network access to Google Cloud APIs

## Usage

Run from this directory (the program reads `permissions.yaml` from the current working directory):

```bash
go run . --org <ORG_ID>
go run . --folder <FOLDER_ID>
go run . --billing <BILLING_ACCOUNT_ID>
```

You can pass multiple scopes at once:

```bash
go run . --org <ORG_ID> --folder <FOLDER_ID> --billing <BILLING_ACCOUNT_ID>
```

Verbose output (prints all allowed permissions, not only missing ones):

```bash
go run . -v --org <ORG_ID>
```

## Output

- Default mode prints only **missing** permissions per scope (or “All permissions are granted”).
- `-v` prints:
  - full list of **allowed** permissions returned by the API
  - any **missing** permissions from `permissions.yaml`

## Notes

- This tool validates permissions of the **credentials used to run it** (your local ADC or your CI/CD identity).
- If a scope is not provided (empty flag), it is skipped.
