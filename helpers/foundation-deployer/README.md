# Terraform Example Foundation deploy helper

Helper tool to deploy the Terraform example foundation using Cloud Build and Cloud Source repositories.

## Usage

## Requirements

- [Go](https://go.dev/doc/install) 1.18+
- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0+
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0+
- [Terraform](https://www.terraform.io/downloads.html) version 1.3.0+
- See `0-bootstrap` README for additional IAM [requirements](../../0-bootstrap/README.md#prerequisites) on the user deploying the Foundation.

### Validate required tools

- Check if required tools, Go 1.18+, Terraform 1.3.0+, gcloud 393.0.0+, and Git 2.28.0+, are installed:

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

In addition to the variables declared in the file `global.tfvars` for configuring location, there are two locals, `default_region1` and `default_region2`, in each one of the environments (`production`, `non-production`, and `development`) in the network steps (`3-networks-dual-svpc` and `3-networks-hub-and-spoke`).
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
