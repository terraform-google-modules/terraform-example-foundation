# 5-app-infra

This repo is part of a multi-part guide that shows how to configure and deploy
the example.com reference architecture described in
[Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations). The following table lists the parts of the guide.

<table>
<tbody>
<tr>
<td><a href="../0-bootstrap">0-bootstrap</a></td>
<td>Bootstraps a Google Cloud organization, creating all the required resources
and permissions to start using the Cloud Foundation Toolkit (CFT). This
step also configures a <a href="../docs/GLOSSARY.md#foundation-cicd-pipeline">CI/CD Pipeline</a> for foundations code in subsequent
stages.</td>
</tr>
<tr>
<td><a href="../1-org">1-org</a></td>
<td>Sets up top-level shared folders, networking projects,
organization-level logging, and baseline security settings through
organizational policies.</td>
</tr>
<tr>
<td><a href="../2-environments"><span style="white-space: nowrap;">2-environments</span></a></td>
<td>Sets up development, nonproduction, and production environments within the
Google Cloud organization that you've created.</td>
</tr>
<tr>
<td><a href="../3-networks-svpc">3-networks-svpc</a></td>
<td>Sets up shared VPCs with default DNS, NAT (optional),
Private Service networking, VPC service controls, on-premises Dedicated
Interconnect, and baseline firewall rules for each environment. It also sets
up the global DNS hub.</td>
</tr>
<tr>
<td><a href="../3-networks-hub-and-spoke">3-networks-hub-and-spoke</a></td>
<td>Sets up shared VPCs with all the default configuration
found on step 3-networks-svpc, but here the architecture will be based on the
Hub and Spoke network model. It also sets up the global DNS hub.</td>
</tr>
<tr>
<td><a href="../4-projects">4-projects</a></td>
<td>Sets up a folder structure, projects, and an application infrastructure pipeline for applications,
 which are connected as service projects to the shared VPC created in the previous stage.</td>
</tr>
<tr>
<td>5-app-infra (this file)</td>
<td>Deploy a simple <a href="https://cloud.google.com/compute/">Compute Engine</a> instance in one of the business unit projects using the infra pipeline set up in 4-projects.</td>
</tr>
</tbody>
</table>

For an overview of the architecture and the parts, see the
[terraform-example-foundation README](https://github.com/terraform-google-modules/terraform-example-foundation)
file.

## Purpose

The purpose of this step is to deploy a simple [Compute Engine](https://cloud.google.com/compute/) instance in one of the business unit projects using the application infrastructure pipeline set up in `4-projects`.
The application infrastructure pipeline is configured in step `4-projects` within the business unit shared environment (`4-projects/business_unit_1/shared`) and supports four deployment methods:
- **GitHub Actions** (keyless authentication via Workload Identity Federation)
- **GitLab CI** (keyless authentication via GitLab OIDC and GCP STS)
- **Local Deployment** (using `./tf-wrapper.sh` with Application Default Credentials and Service Account impersonation)
- **Cloud Build** (for existing organizations with Cloud Source Repositories)

As part of this deployment, the provided Terraform code automates the provisioning of secure infrastructure in Google Cloud to run workloads in [Confidential Space](https://cloud.google.com/confidential-computing/confidential-space/docs/confidential-space-overview) — based on Confidential VMs with hardware attestation, data isolation, trusted container execution, and integration with Cloud KMS for encryption and Cloud Storage for attestation tokens. In addition to this documentation, you can follow Google's official tutorial: [Create your first Confidential Space environment](https://cloud.google.com/confidential-computing/confidential-space/docs/create-your-first-confidential-space-environment).

To better understand the structure and content of the tokens used in Confidential Space, refer to the reference documentation on [Token Claims](https://cloud.google.com/confidential-computing/confidential-space/docs/reference/token-claims).

This Compute Engine instance is deployed into the Shared VPC network configured in step `3-networks` and is used to access private services across environments (`development`, `nonproduction`, `production`).

## Prerequisites

1. `0-bootstrap` executed successfully.
2. `1-org` executed successfully.
3. `2-environments` executed successfully.
4. `3-networks` executed successfully.
5. `4-projects` executed successfully (including `business_unit_1/shared` and the environment service projects).

### Required Tooling

To run the commands described in this document, install the following tools:
- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7 or later
- [jq](https://jqlang.github.io/jq/download/) version 1.6.0 or later

### Runner Matrix & Prerequisites Overview

| Deployment Method | Authentication Mechanism | Required Credentials / Tokens | Remote State Storage |
| :--- | :--- | :--- | :--- |
| **GitHub Actions** | Workload Identity Federation (WIF) | GitHub PAT (`repo` scope, used in step 4 to inject secrets) | Dedicated App State Bucket (`*-state`) |
| **GitLab CI** | GitLab OIDC via GCP STS | GitLab Token (`api` scope, used in step 4 to inject variables) | Dedicated App State Bucket (`*-state`) |
| **Local Deploy** | Service Account Impersonation | `gcloud auth application-default login` + Token Creator role | Dedicated App State Bucket (`*-state`) |
| **Cloud Build** | Native Google IAM | Google Cloud IAM permissions (Cloud Build Editor / Runner) | Dedicated App State Bucket (`*-state`) |

### Troubleshooting

Please refer to [troubleshooting](../docs/TROUBLESHOOTING.md) if you run into issues during this step.

## Usage

**General Notes:**
- For Confidential Space, additional firewall rules and directional perimeter rules may be required, depending on the additional workloads to be deployed.
- If you are using macOS, replace `cp -RT` with `cp -R` in the relevant commands. The `-T` flag is standard on Linux/GNU coreutils, but is unsupported on macOS BSD `cp`.
- All automated CI workflows (GitHub Actions, GitLab CI, Cloud Build) automatically substitute `UPDATE_APP_INFRA_BUCKET` in `backend.tf` with the application state bucket configured for the repository.

---

### Deploying with GitHub Actions

When deploying with GitHub Actions, the application infrastructure pipeline created in `4-projects/business_unit_1/shared` provisions a Workload Identity Pool and automatically configures repository secrets in the target GitHub repository (`bu1-example-app`):
- `PROJECT_ID`: The application infrastructure CI/CD project ID.
- `WIF_PROVIDER_NAME`: The full resource name of the Workload Identity Provider.
- `TF_BACKEND`: The dedicated GCS state bucket created for `bu1-example-app`.
- `SERVICE_ACCOUNT_EMAIL`: The dedicated application Terraform service account (`sa-tf-bu1-example-app@...`).

Because these secrets are injected automatically by Terraform in step `4-projects`, zero manual secret management is required.

#### Step 1: Clone the Application Repository

Clone the private repository created to host the `5-app-infra` code. The following instructions assume `bu1-example-app` is cloned at the same directory level as `terraform-example-foundation`.

```bash
git clone git@github.com:<GITHUB-OWNER>/bu1-example-app.git
cd bu1-example-app
```

#### Step 2: Seed Repository Branches

If the repository has not been initialized with environment branches, initialize the named environment branches:

```bash
git commit --allow-empty -m 'repository seed'
git push --set-upstream origin main

git checkout -b production
git push --set-upstream origin production

git checkout -b nonproduction
git push --set-upstream origin nonproduction

git checkout -b development
git push --set-upstream origin development
```

#### Step 3: Checkout the Plan Branch & Copy Foundation Files

```bash
git checkout -b plan

# Copy application infrastructure code
cp -RT ../terraform-example-foundation/5-app-infra/ .

# Copy policy library for automated compliance validation
cp -RT ../terraform-example-foundation/policy-library/ ./policy-library

# Set up GitHub Actions CI workflows and execution wrapper
mkdir -p .github/workflows
cp ../terraform-example-foundation/build/github-tf-* ./.github/workflows/
cp ../terraform-example-foundation/build/tf-wrapper.sh .
chmod 755 ./tf-wrapper.sh
```

#### Step 4: Configure `common.auto.tfvars`

Rename the example tfvars file and populate environment inputs:

```bash
mv common.auto.example.tfvars common.auto.tfvars

# Set the remote state bucket pointing to 4-projects state
export remote_state_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw projects_gcs_bucket_tfstate)
echo "remote_state_bucket = ${remote_state_bucket}"
sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
```

Configure Confidential Space container image and digest:
- If using the image built in the `tf-runners` Artifact Registry in `cicd_project_id`:

  ```bash
  export CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/shared/" output -raw cicd_project_id)
  export DEFAULT_REGION=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/shared/" output -raw default_region)
  export IMAGE_DIGEST=$(gcloud artifacts docker images describe ${DEFAULT_REGION}-docker.pkg.dev/${CICD_PROJECT_ID}/tf-runners/confidential_space_image:latest --format="value(image_summary.digest)")
  sed -i'' -e "s/IMAGE_DIGEST/${IMAGE_DIGEST}/" ./common.auto.tfvars
  ```

- Alternatively, if using an existing custom container image from another registry:

  ```bash
  export CUSTOM_TEE_IMAGE="us-central1-docker.pkg.dev/YOUR_PROJECT/YOUR_REPO/YOUR_IMAGE:latest"
  export IMAGE_DIGEST=$(gcloud artifacts docker images describe ${CUSTOM_TEE_IMAGE} --format="value(image_summary.digest)")
  sed -i'' -e "s|# custom_tee_image_reference = .*|custom_tee_image_reference = \"${CUSTOM_TEE_IMAGE}\"|" ./common.auto.tfvars
  sed -i'' -e "s/IMAGE_DIGEST/${IMAGE_DIGEST}/" ./common.auto.tfvars
  ```

> [!NOTE]
> The GitHub Actions workflow automatically substitutes `UPDATE_APP_INFRA_BUCKET` in all `backend.tf` files using the injected `TF_BACKEND` secret during pipeline execution. You do not need to manually edit `backend.tf`.

#### Step 5: Commit and Push the Plan Branch

```bash
git add .
git commit -m 'feat: initialize bu1-example-app infrastructure'
git push --set-upstream origin plan
```

#### Step 6: Review Plan and Deploy Environments

1. **Deploy Development:**
   - In GitHub, open a Pull Request from `plan` to `development`.
   - The Pull Request triggers the `tf-pull-request` workflow, which executes `terraform init`, `plan`, and `validate` via WIF authentication.
   - Review the plan output in the GitHub Actions tab.
   - Once approved, merge the Pull Request into `development`. Merging triggers `tf-apply`, applying the Terraform configuration in the `development` service projects.

2. **Promote to Nonproduction:**
   - Open a Pull Request from `development` to `nonproduction`.
   - Review the plan output in GitHub Actions.
   - Merge the Pull Request into `nonproduction` to apply.

3. **Promote to Production:**
   - Open a Pull Request from `nonproduction` to `production`.
   - Review the plan output in GitHub Actions.
   - Merge the Pull Request into `production` to apply.

---

### Deploying with GitLab CI

When deploying with GitLab CI, the application infrastructure pipeline created in `4-projects/business_unit_1/shared` provisions GitLab OIDC provider trust and automatically configures CI/CD variables in the target GitLab project (`bu1-example-app`):
- `PROJECT_ID`: The application infrastructure CI/CD project ID.
- `WIF_PROVIDER_NAME`: The full resource name of the Workload Identity Provider.
- `TF_BACKEND`: The dedicated GCS state bucket created for `bu1-example-app`.
- `SERVICE_ACCOUNT_EMAIL`: The dedicated application Terraform service account (`sa-tf-bu1-example-app@...`).

#### Step 1: Clone the Application Project

Clone the project from GitLab at the same directory level as `terraform-example-foundation`:

```bash
git clone git@gitlab.com:<GITLAB-GROUP>/bu1-example-app.git
cd bu1-example-app
```

#### Step 2: Seed Project Branches

If the GitLab project is newly created, initialize the environment branches:

```bash
git commit --allow-empty -m 'repository seed'
git push --set-upstream origin main

git checkout -b production
git push --set-upstream origin production

git checkout -b nonproduction
git push --set-upstream origin nonproduction

git checkout -b development
git push --set-upstream origin development
```

#### Step 3: Checkout the Plan Branch & Copy Foundation Files

```bash
git checkout -b plan

# Copy application infrastructure code
cp -RT ../terraform-example-foundation/5-app-infra/ .

# Copy policy library
cp -RT ../terraform-example-foundation/policy-library/ ./policy-library

# Copy GitLab CI pipeline and authentication scripts
cp ../terraform-example-foundation/build/gitlab-ci.yml ./.gitlab-ci.yml
cp ../terraform-example-foundation/build/run_gcp_auth.sh .
cp ../terraform-example-foundation/build/tf-wrapper.sh .
chmod 755 ./*.sh
```

#### Step 4: Configure `common.auto.tfvars`

```bash
mv common.auto.example.tfvars common.auto.tfvars

# Set the remote state bucket pointing to 4-projects state
export remote_state_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw projects_gcs_bucket_tfstate)
echo "remote_state_bucket = ${remote_state_bucket}"
sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
```

Configure Confidential Space container image and digest:
- If using the image in the `tf-runners` Artifact Registry:

  ```bash
  export CICD_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/shared/" output -raw cicd_project_id)
  export DEFAULT_REGION=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/shared/" output -raw default_region)
  export IMAGE_DIGEST=$(gcloud artifacts docker images describe ${DEFAULT_REGION}-docker.pkg.dev/${CICD_PROJECT_ID}/tf-runners/confidential_space_image:latest --format="value(image_summary.digest)")
  sed -i'' -e "s/IMAGE_DIGEST/${IMAGE_DIGEST}/" ./common.auto.tfvars
  ```

- Alternatively, if using a custom image reference:

  ```bash
  export CUSTOM_TEE_IMAGE="us-central1-docker.pkg.dev/YOUR_PROJECT/YOUR_REPO/YOUR_IMAGE:latest"
  export IMAGE_DIGEST=$(gcloud artifacts docker images describe ${CUSTOM_TEE_IMAGE} --format="value(image_summary.digest)")
  sed -i'' -e "s|# custom_tee_image_reference = .*|custom_tee_image_reference = \"${CUSTOM_TEE_IMAGE}\"|" ./common.auto.tfvars
  sed -i'' -e "s/IMAGE_DIGEST/${IMAGE_DIGEST}/" ./common.auto.tfvars
  ```

> [!NOTE]
> The GitLab CI pipeline automatically substitutes `UPDATE_APP_INFRA_BUCKET` in all `backend.tf` files using the injected `TF_BACKEND` variable. You do not need to manually edit `backend.tf`.

#### Step 5: Commit and Push the Plan Branch

```bash
git add .
git commit -m 'feat: initialize bu1-example-app infrastructure'
git push --set-upstream origin plan
```

#### Step 6: Review Plan and Deploy Environments via Merge Requests

1. **Deploy Development:**
   - In GitLab, open a Merge Request from `plan` to `development`.
   - The Merge Request triggers the `terraform-plan-mr` pipeline job using GitLab OIDC token exchange.
   - Review the plan output in the GitLab CI/CD pipeline logs.
   - Merge the Merge Request into `development`. Merging triggers `terraform-apply`, applying the Terraform configuration in `development`.

2. **Promote to Nonproduction:**
   - Open a Merge Request from `development` to `nonproduction`.
   - Review the plan output in GitLab CI/CD.
   - Merge into `nonproduction` to apply.

3. **Promote to Production:**
   - Open a Merge Request from `nonproduction` to `production`.
   - Review the plan output in GitLab CI/CD.
   - Merge into `production` to apply.

---

### Running Terraform Locally

When deploying locally without a remote VCS runner, execution uses `./tf-wrapper.sh` powered by [Application Default Credentials (ADC)](https://cloud.google.com/docs/authentication/application-default-credentials) and [Service Account Impersonation](https://cloud.google.com/docs/authentication/use-service-account-impersonation).

#### Step 1: Authenticate with Google Cloud

Ensure you are authenticated with user credentials and have active Application Default Credentials:

```bash
gcloud auth login
gcloud auth application-default login
```

#### Step 2: Prepare Execution Directory

Navigate to `5-app-infra` (or your local working directory), copy the execution wrapper, and make it executable:

```bash
cd terraform-example-foundation/5-app-infra
cp ../build/tf-wrapper.sh .
chmod 755 ./tf-wrapper.sh
```

#### Step 3: Configure `common.auto.tfvars`

```bash
mv common.auto.example.tfvars common.auto.tfvars

# Set the remote state bucket pointing to 4-projects state
export remote_state_bucket=$(terraform -chdir="../0-bootstrap/" output -raw projects_gcs_bucket_tfstate)
echo "remote_state_bucket = ${remote_state_bucket}"
sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars
```

Configure Confidential Space container image and digest:
When deploying locally (`build_type = local`), there is no automated CI/CD pipeline that builds `confidential_space_image:latest`. To test or run Confidential Space locally, specify a custom container image reference in `custom_tee_image_reference` and its SHA256 digest in `confidential_image_digest`:

```bash
export CUSTOM_TEE_IMAGE="us-central1-docker.pkg.dev/YOUR_PROJECT/YOUR_REPO/YOUR_IMAGE:latest"
export IMAGE_DIGEST=$(gcloud artifacts docker images describe ${CUSTOM_TEE_IMAGE} --format="value(image_summary.digest)")

sed -i'' -e "s|# custom_tee_image_reference = .*|custom_tee_image_reference = \"${CUSTOM_TEE_IMAGE}\"|" ./common.auto.tfvars
sed -i'' -e "s/IMAGE_DIGEST/${IMAGE_DIGEST}/" ./common.auto.tfvars
```

> [!NOTE]
> Hardware attestation in Confidential Space requires the image digest in `confidential_image_digest` to exactly match the signed container running in the enclave. If you are not testing Confidential Space enclaves, any syntactically valid SHA256 string (for example, `sha256:0000000000000000000000000000000000000000000000000000000000000000`) satisfies Terraform validation for the instance template.

#### Step 4: Grant Token Creator Role on the Application Service Account

Grant the active user the `roles/iam.serviceAccountTokenCreator` role on the application Terraform service account created in `4-projects/business_unit_1/shared`:

```bash
export member="user:$(gcloud auth list --filter="status=ACTIVE" --format="value(account)")"
echo "Active user: ${member}"

export terraform_sa=$(terraform -chdir="../4-projects/business_unit_1/shared/" output -json terraform_service_accounts | jq -r '."bu1-example-app"')
echo "Target SA: ${terraform_sa}"

gcloud iam service-accounts add-iam-policy-binding "${terraform_sa}" \
  --member="${member}" \
  --role="roles/iam.serviceAccountTokenCreator"
```

#### Step 5: Update `backend.tf` Files with App State Bucket

Retrieve the dedicated application state bucket name from `4-projects/shared` and update the backends:

```bash
export backend_bucket=$(terraform -chdir="../4-projects/business_unit_1/shared/" output -json state_buckets | jq -r '."bu1-example-app"')
echo "backend_bucket = ${backend_bucket}"

for i in `find . -name 'backend.tf'`; do
  sed -i'' -e "s/UPDATE_APP_INFRA_BUCKET/${backend_bucket}/" $i
done
```

#### Step 6: Deploy Environments with Service Account Impersonation

Enable service account impersonation for the Terraform Google provider:

```bash
export GOOGLE_IMPERSONATE_SERVICE_ACCOUNT=${terraform_sa}
```

Deploy the environments in sequence (`development`, `nonproduction`, `production`):

```bash
# 1. Deploy Development
./tf-wrapper.sh init development
./tf-wrapper.sh plan development
./tf-wrapper.sh apply development

# 2. Deploy Nonproduction
./tf-wrapper.sh init nonproduction
./tf-wrapper.sh plan nonproduction
./tf-wrapper.sh apply nonproduction

# 3. Deploy Production
./tf-wrapper.sh init production
./tf-wrapper.sh plan production
./tf-wrapper.sh apply production
```

> [!NOTE]
> If you modify Terraform configurations or `common.auto.tfvars`, re-run `./tf-wrapper.sh plan <env>` before running `./tf-wrapper.sh apply <env>`.

#### Step 7: Clean Up Environment Variables

After completing deployment, unset the impersonation variable:

```bash
unset GOOGLE_IMPERSONATE_SERVICE_ACCOUNT
```

---

### Deploying with Cloud Build (Legacy CSR)

> [!WARNING]
> This deployment method depends on [Google Cloud Source Repositories (CSR)](https://cloud.google.com/source-repositories), which is **no longer available to new customers**. Organizations that have not previously used CSR will not be able to enable the `sourcerepo.googleapis.com` API and cannot use this deployment method. For all new foundation deployments, use [GitHub Actions](#deploying-with-github-actions), [GitLab CI](#deploying-with-gitlab-ci), or [Local Deployment](#running-terraform-locally).

If your Google Cloud organization has existing access to CSR and you selected `build_type = "cb"` during `0-bootstrap` and `4-projects`, follow these steps:

#### Step 1: Initialize the Policy Library Repository

```bash
export INFRA_PIPELINE_PROJECT_ID=$(terraform -chdir="../4-projects/business_unit_1/shared/" output -raw cloudbuild_project_id)
echo "Infra Pipeline Project: ${INFRA_PIPELINE_PROJECT_ID}"

# Clone gcp-policies repo created in the app-infra pipeline project
gcloud source repos clone gcp-policies gcp-policies-app-infra --project=${INFRA_PIPELINE_PROJECT_ID}
cd gcp-policies-app-infra
git checkout -b main

# Copy policy library contents
cp -RT ../terraform-example-foundation/policy-library/ .

git add .
git commit -m 'feat: initialize policy library repo'
git push --set-upstream origin main
cd ..
```

#### Step 2: Clone `bu1-example-app` and Prepare Files

```bash
gcloud source repos clone bu1-example-app --project=${INFRA_PIPELINE_PROJECT_ID}
cd bu1-example-app
git checkout -b plan

# Copy application infrastructure files and Cloud Build build templates
cp -RT ../terraform-example-foundation/5-app-infra/ .
cp ../terraform-example-foundation/build/cloudbuild-tf-* .
cp ../terraform-example-foundation/build/tf-wrapper.sh .
chmod 755 ./tf-wrapper.sh
```

#### Step 3: Configure `common.auto.tfvars`

```bash
mv common.auto.example.tfvars common.auto.tfvars

# Set remote state bucket
export remote_state_bucket=$(terraform -chdir="../terraform-example-foundation/0-bootstrap/" output -raw projects_gcs_bucket_tfstate)
sed -i'' -e "s/REMOTE_STATE_BUCKET/${remote_state_bucket}/" ./common.auto.tfvars

# Resolve Confidential Space image digest built during step 4-projects
export DEFAULT_REGION=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/shared" output -raw default_region)
export confidential_image_digest=$(gcloud artifacts docker images describe ${DEFAULT_REGION}-docker.pkg.dev/${INFRA_PIPELINE_PROJECT_ID}/tf-runners/confidential_space_image:latest --format="value(image_summary.digest)" --project=${INFRA_PIPELINE_PROJECT_ID})
echo "confidential_image_digest = ${confidential_image_digest}"

sed -i'' -e "s/IMAGE_DIGEST/${confidential_image_digest}/" ./common.auto.tfvars
```

> [!NOTE]
> The Cloud Build build steps (`cloudbuild-tf-plan.yaml` and `cloudbuild-tf-apply.yaml`) automatically substitute `UPDATE_APP_INFRA_BUCKET` in all `backend.tf` files with the dedicated state bucket. You do not need to manually edit `backend.tf`.

#### Step 4: Commit and Push Plan Branch

```bash
git add .
git commit -m 'feat: initialize bu1-example-app infrastructure'
git push --set-upstream origin plan
```

Pushing to `plan` triggers a Cloud Build plan build across all environments. Review the build output in the Google Cloud Console:
`https://console.cloud.google.com/cloud-build/builds?project=${INFRA_PIPELINE_PROJECT_ID}`

#### Step 5: Deploy Environments via Named Branches

1. **Deploy Development:**
   ```bash
   git checkout -b development
   git push origin development
   ```
   Pushing to `development` triggers both `terraform plan` and `terraform apply` for the development environment.

2. **Deploy Nonproduction:**
   ```bash
   git checkout -b nonproduction
   git push origin nonproduction
   ```

3. **Deploy Production:**
   ```bash
   git checkout -b production
   git push origin production
   ```

---

## Post-Deployment Validation

After deploying `5-app-infra`, verify that the expected resources are active across each environment:

### 1. Verify Compute Engine Instances

Check that the sample Compute Engine VM (`sample-svpc`) is running inside the Shared VPC service project:

```bash
# Retrieve development project ID
export DEV_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/development/" output -raw shared_vpc_project)
gcloud compute instances list --project="${DEV_PROJECT_ID}"
```

Expected output confirms the VM instance is `RUNNING` and attached to the Shared VPC subnetwork:
```text
NAME         ZONE           MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP  STATUS
sample-svpc  us-central1-a  e2-micro                    10.0.64.x                 RUNNING
```

### 2. Verify Confidential Space Resources

Verify that the Confidential Space instance template and Workload Identity Pool were created in the confidential computing project:

```bash
export CONF_PROJECT_ID=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/development/" output -raw confidential_space_project)

# List Instance Templates
gcloud compute instance-templates list --project="${CONF_PROJECT_ID}"

# Verify Workload Identity Pool
gcloud iam workload-identity-pools describe "confidential-space-pool" \
  --location="global" \
  --project="${CONF_PROJECT_ID}"
```

### 3. Verify Remote State Backend

Verify that application state is stored in the dedicated application state bucket:

```bash
export TF_STATE_BUCKET=$(terraform -chdir="../terraform-example-foundation/4-projects/business_unit_1/shared/" output -json state_buckets | jq -r '."bu1-example-app"')
gsutil ls -r "gs://${TF_STATE_BUCKET}/terraform/app-infra/"
```

Expected output confirms dedicated per-environment state isolation:
```text
gs://${TF_STATE_BUCKET}/terraform/app-infra/business_unit_1/development/default.tfstate
gs://${TF_STATE_BUCKET}/terraform/app-infra/business_unit_1/nonproduction/default.tfstate
gs://${TF_STATE_BUCKET}/terraform/app-infra/business_unit_1/production/default.tfstate
```
