# Terraform Example Foundation deploy helper

Helper tool to deploy the Terraform example foundation using Cloud Build and Cloud Source repositories.

## Usage

## Requirements

- [Go](https://go.dev/doc/install) 1.22 or later
- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0 or later
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7 or later
- See `0-bootstrap` README for additional IAM [requirements](../../0-bootstrap/README.md#prerequisites) on the user deploying the Foundation.

Your environment need to use the same [Terraform](https://www.terraform.io/downloads.html) version used on the build pipeline.
Otherwise, you might experience Terraform state snapshot lock errors.

Version 1.5.7 is the last version before the license model change. To use a later version of Terraform, ensure that the Terraform version used in the Operational System to manually execute part of the steps in `3-networks` and `4-projects` is the same version configured in the following code

- 0-bootstrap/modules/jenkins-agent/variables.tf
   ```
   default     = "1.5.7"
   ```

- 0-bootstrap/cb.tf
   ```
   terraform_version = "1.5.7"
   ```

- scripts/validate-requirements.sh
   ```
   TF_VERSION="1.5.7"
   ```

- build/github-tf-apply.yaml
   ```
   terraform_version: '1.5.7'
   ```

- github-tf-pull-request.yaml

   ```
   terraform_version: "1.5.7"
   ```

- 0-bootstrap/Dockerfile
   ```
   ARG TERRAFORM_VERSION=1.5.7
   ```

### Validate required tools

- Check if required tools, Go 1.22.0+, Terraform 1.5.7+, gcloud 393.0.0+, and Git 2.28.0+, are installed:

    ```bash
    go version

    terraform -version

    gcloud --version

    git --version
    ```

- check if required components of `gcloud` are installed:

    ```bash
    gcloud components list --filter="id=beta OR id=terraform-tools"
    ```

- Follow the instructions in the output of the command if components `beta` and `terraform-tools` are not installed to install them.

### Prepare the deploy environment

- Create a directory in the file system to host the Cloud Source repositories the will be created and a copy of the terraform example foundation.
- Clone the `terraform-example-foundation` repository on this directory.

    ```text
    deploy-directory/
    └── terraform-example-foundation
    ```

- Copy the file [global.tfvars.example](./global.tfvars.example) as `global.tfvars` to the same directory.

    ```text
    deploy-directory/
    └── global.tfvars
    └── terraform-example-foundation
    ```

- Update `global.tfvars` with values from your environment.
- The `0-bootstrap` README [prerequisites](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md#prerequisites)  section has additional prerequisites needed to run this helper.
- Variable `code_checkout_path` is the full path to `deploy-directory` directory.
- Variable `foundation_code_path` is the full path to `terraform-example-foundation` directory.
- See the READMEs for the stages for additional information:
  - [0-bootstrap](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md)
  - [1-org](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/1-org/README.md)
  - [2-environments](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/2-environments/README.md)
  - [3-networks-dual-svpc](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/3-networks-dual-svpc)
  - [3-networks-hub-and-spoke](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/3-networks-hub-and-spoke)
  - [4-projects](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects)
  - [5-app-infra](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/5-app-infra)

### Location

By default the foundation regional resources are deployed in `us-west1` and `us-central1` regions and multi-regional resources are deployed in the `US` multi-region.

In addition to the variables declared in the file `global.tfvars` for configuring location, there are two locals, `default_region1` and `default_region2`, in each one of the environments (`production`, `nonproduction`, and `development`) in the network steps (`3-networks-dual-svpc` and `3-networks-hub-and-spoke`).
They are located in the [main.tf](../../3-networks-dual-svpc/envs/production/main.tf#L20-L21) files for each environments.
Change the two locals **before** starting the deployment to deploy in other regions.

**Note:** the region used for the variable `default_region` in the file `global.tfvars` **MUST** be one of the regions used for the `default_region1` and `default_region2` locals.

### Application default credentials

- Set the billing quota project in the `gcloud` configuration

    ```
    gcloud config set billing/quota_project <QUOTA-PROJECT>

    gcloud services enable \
    "cloudresourcemanager.googleapis.com" \
    "iamcredentials.googleapis.com" \
    "cloudbuild.googleapis.com" \
    "securitycenter.googleapis.com" \
    "accesscontextmanager.googleapis.com" \
    --project <QUOTA-PROJECT>
    ```

- Configure [Application Default Credentials](https://cloud.google.com/sdk/gcloud/reference/auth/application-default/login)

    ```bash
    gcloud auth application-default login
    ```

### Run the helper

- Install the helper:

    ```bash
    go install
    ```

- Validate the tfvars file. If you configured a `validator_project_id` in the `global.tfvars` file the `validate` flag will do additional checks for the Secure Command Center notification name and for the Tag Key name.
For these extra check you need at least the roles *Security Center Notification Configurations Viewer* (`roles/securitycenter.notificationConfigViewer`) and *Tag Viewer* (`roles/resourcemanager.tagViewer`):

    ```bash
    $HOME/go/bin/foundation-deployer -tfvars_file <PATH TO 'global.tfvars' FILE> -validate
    ```

- Run the helper:

    ```bash
    $HOME/go/bin/foundation-deployer -tfvars_file <PATH TO 'global.tfvars' FILE>
    ```

- To Suppress additional output use:

    ```bash
    $HOME/go/bin/foundation-deployer -tfvars_file <PATH TO 'global.tfvars' FILE> -quiet
    ```

- To destroy the deployment run:

    ```bash
    $HOME/go/bin/foundation-deployer -tfvars_file <PATH TO 'global.tfvars' FILE> -destroy
    ```

- After deployment:

    ```text
    deploy-directory/
    └── bu1-example-app
    └── gcp-bootstrap
    └── gcp-environments
    └── gcp-networks
    └── gcp-org
    └── gcp-policies
    └── gcp-policies-app-infra
    └── gcp-projects
    └── global.tfvars
    └── terraform-example-foundation
    ```

### Supported flags

```bash
  -tfvars_file file
        Full path to the Terraform .tfvars file with the configuration to be used.
  -steps_file file
        Path to the steps file to be used to save progress. (default ".steps.json")
  -list_steps
        List the existing steps.
  -reset_step step
        Name of a step to be reset. The step will be marked as pending.
  -validate
        Validate tfvars file inputs
  -quiet
        If true, additional output is suppressed.
  -disable_prompt
        Disable interactive prompt.
  -destroy
        Destroy the deployment.
  -help
        Prints this help text and exits.
```

## Troubleshooting

See [troubleshooting](../../docs/TROUBLESHOOTING.md) if you run into issues during this deploy.
