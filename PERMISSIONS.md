# Required Permissions for Enterprise Landing Zone

This document summarizes the permissions needed to successfully deploy the Enterprise Landing Zone blueprints, specifically highlighting the ones that caused issues due to permission boundaries.

You can use this list to request the necessary access from your **Organization Admin** and **Billing Administrator**.

## 1. Permissions for the Service Accounts (Automated Deployment)

These are the most critical permissions needed for the GitHub Actions workflows to run successfully without manual workarounds.

### A. On the Billing Account
The following permission is needed on the Billing Account (`01D920-A90EFC-E7459C`):

| Service Account | Role Needed | Rationale |
| :--- | :--- | :--- |
| `sa-terraform-org@food-b-seed-bf76.iam.gserviceaccount.com` | **`roles/billing.user`** | Required to associate newly created projects (Logging, Billing Export, etc.) with the billing account. |

> [!IMPORTANT]
> Lack of this permission forced us to use a workaround where projects are created without billing, and must be linked manually.

### B. On the Organization Level
These roles were successfully granted during Step 0, but are listed here for completeness or if they need to be verified by an admin.

| Service Account | Roles Needed | Rationale |
| :--- | :--- | :--- |
| `sa-terraform-org@...` | `roles/orgpolicy.policyAdmin`<br>`roles/logging.configWriter`<br>`roles/resourcemanager.organizationAdmin`<br>`roles/cloudasset.owner`<br>`roles/browser` | Required to create folders, set organization policies, configure log sinks, and run security validation (`terraform vet`). |

---

## 2. Permissions for the Cloud User (You)

If you need to perform manual steps or troubleshooting, you need these permissions.

### A. On the Billing Account
| Identity | Role Needed | Rationale |
| :--- | :--- | :--- |
| Your User Account | **`roles/billing.user`** | Required to manually link projects to the billing account in the Cloud Console (our current workaround). |
| Your User Account | **`roles/billing.admin`** (Optional) | Only needed if you need to grant permissions to the service accounts yourself. |

### B. On the Organization Level
| Identity | Role Needed | Rationale |
| :--- | :--- | :--- |
| Your User Account | `roles/resourcemanager.organizationAdmin` | Needed to run the initial bootstrap step and manage organization resources. |
| Your User Account | `roles/accesscontextmanager.policyAdmin` | Needed to manage Access Policies (which caused a conflict in Step 1). |

---

## 3. General Permissions for Creating Future Projects

When you want to create new projects in the future (e.g., in Step 4 or for new business units), the **Service Account running that step** (or your user account if running locally) will generally need the following permissions.

### A. On the Billing Account
| Identity | Role Needed | Rationale |
| :--- | :--- | :--- |
| Service Account or User | **`roles/billing.user`** | **CRITICAL:** Any entity creating a project and wanting it to be usable must be able to associate it with a billing account. |

### B. On the Folder or Organization Level
| Identity | Role Needed | Rationale |
| :--- | :--- | :--- |
| Service Account or User | `roles/resourcemanager.projectCreator` | Needed to create new projects within a folder or organization. |
| Service Account or User | `roles/resourcemanager.projectDeleter` | Needed if you want to be able to delete projects via Terraform. |
| Service Account or User | `roles/browser` | Recommended for validation tools to read ancestry. |
