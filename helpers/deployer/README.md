# Terraform Example Foundation deploy helper

Helper tool to deploy the Terraform example foundation.

## Usage

- Check if required tools, Go 1.18+, Terraform 1.3.0+, gcloud 393.0.0+, and Git 2.28.0+, are installed:

    ```bash
    go version

    terraform -version

    gcloud --version

    git --version
    ```

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
See the READMEs for the stages for additional information:
  - [0-bootstrap](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/0-bootstrap/README.md)
  - [1-org](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/1-org/README.md)
  - [2-environments](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/2-environments/README.md)
  - [3-networks-dual-svpc](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/3-networks-dual-svpc)
  - [3-networks-hub-and-spoke](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/3-networks-hub-and-spoke)
  - [4-projects](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/4-projects)
  - [5-app-infra](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/5-app-infra)

- Variable `code_checkout_path` is the full path to `deploy-directory` directory.
- Variable `foundation_code_path` is the full path to `terraform-example-foundation` directory.
- Build the helper:

    ```bash
    go build
    ```

- Validate the tfvars file:

    ```bash
    ./deployer -tfvars_file <PATH TO 'global.tfvars' FILE> -validate
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
        Name of a step to be reset.
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

## Requirements

- [Go](https://go.dev/doc/install) 1.18+
- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 393.0.0+
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.28.0+
- [Terraform](https://www.terraform.io/downloads.html) version 1.3.0+
- See `0-bootstrap` README for additional IAM [requirements](../../0-bootstrap/README.md#prerequisites) on the user deploying the Foundation.
