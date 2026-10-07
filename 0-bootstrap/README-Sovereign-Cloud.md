# Deploying a Sovereign Cloud compatible environment

The objective of the following instructions is to explain the use of Deploy Helper to deploy the Terraform Example Foundation on a Sovereign Cloud.

This deployment is a subset of the options available in the original Google Cloud.

## Requirements

To run the instructions described in this document, install the following:

- [Go](https://go.dev/doc/install) 1.25 or later
- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 568.0.0 or later
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) version 2.54.0 or later
- [Terraform](https://www.terraform.io/downloads.html) version 1.5.7

Terraform version 1.5.7 is the last version before the license model change.

## Differences

These are some of differences of the Sovereign Cloud deploy to a deployment in the original Google Cloud

- The deploy is single region
- It uses WorkForce Federation users for authentication
- It has a selection of Services from the ones available in the original Google Cloud
- The Services have a custom endpoint
- Security Command Center is not available
- Project IDs have a prefix e.g. `prefix:base-project-id`
- Service agent service accounts have different domains
- Cloud Build is not available
- VPC-SC users (WorkForce Federation users) are added in ingress rules instead of Access Context Manager Access level Members
- Deploy is done locally using `terraform` and code is saved in local git repositories.
- Essential Contacts configuration will be done in your onboarding not in the Foundation deploy
- The organization policy that prevents the creation of the default network is always on and is not available to be changed
- There are some limitations to the centralized logging configuration

## Instructions

Follow the instructions in your onboarding documentation to configure your initial access.

### Authentication

Follow the instructions in your onboarding documentation on how to create the [WorkForce Federation](https://docs.cloud.google.com/iam/docs/workforce-identity-federation) configuration for your external identity provider.

You will need at least a Principal and a PrincipalSet for each of the required groups in step 0-bootstrap. The PrincipalSets will be used as replacement for the groups.

Follow the instructions in your onboarding documentation on how to create the WorkForce Federation [login config file](https://docs.cloud.google.com/iam/docs/workforce-log-in-gcloud). Name it `wif-login-config.json`

Login to the Google Cloud SDK and configure Application Default Credentials

```sh
gcloud auth login --login-config <PATH_TO/wif-login-config.json>

gcloud auth application-default login  --login-config <PATH_TO/wif-login-config.json>
```

When asked if you want to change the universe domain configuration accept the suggested change.

### Configuration

1. Create a file system directory to host the deployment. The git repositories with the deployment will be create under this directory. This will be the `code_checkout_path`.
1. Copy the file [global.tfvars.example](../helpers/foundation-deployer/global.tfvars.example) to this directory and rename it to `global.tfvars`
1. Git clone this repository inside the `code_checkout_path`
    ```sh
    git clone <REPOSITORY_URL> terraform-example-foundation
    ```
1. Cd into `terraform-example-foundation`
    ```sh
    cd terraform-example-foundation
    ```
1. Change to the Google Universe support branch
    ```sh
    git checkout feat/google-universe-support
    ```
1. The folder structure should be
    ```
    code_checkout_path/
    ├── global.tfvars
    └── terraform-example-foundation/
    ```
1. Install the [foundation-deployer](../helpers/foundation-deployer/README.md) helper
    ```sh
    cd helpers/foundation-deployer

    go install
    ```

#### Configure global.tfvars

Use the inline instructions of the file.

The configuration under `Google universe configuration` require values from your Sovereign Cloud environment.
- `universe_prefix`, `universe_domain`, and `pkg_dev_domain` should be in your onboarding configuration or your Sovereign Cloud documentation.
- `enable_gcr_dns` should be set to false.
- The values under `available_universe_services` should also be set to false.
- Uncomment `principal_set_org_ids` and set it with your Organization ID
- Update `groups.required_groups` with the principalSets created. format is "principalSet://iam.googleapis.com/locations/global/workforcePools/POOL-ID/group/GROUP-ID"
- Update `perimeter_additional_members` with your principal. The item format is "principal://iam.googleapis.com/locations/global/workforcePools/POOL-ID/subject/SUBJECT-ID". It is the same one that is in the IAM console.
- Set `allow_additional_member_types` to `true`


### Validate global.tfvars configuration

To validate configuration on the `global.tfvars` file run:

```sh
foundation-deployer -tfvars_file  <PATH-TO/global.tfvars> -validate
```

### Terraform Example Foundation Deploy

To deploy the Terraform Example Foundation run

```sh
foundation-deployer -tfvars_file  <PATH-TO/global.tfvars> -disable_prompt
```

After the deployment the folder structure should be

```
code_checkout_path/
├── bu1-example-app/
├── gcp-bootstrap/
├── gcp-environments/
├── gcp-networks/
├── gcp-org/
├── gcp-projects/
├── global.tfvars
└── terraform-example-foundation/
```

### Destroying the deployment

To destroy the deployment run:

```sh
foundation-deployer -tfvars_file  <PATH-TO/global.tfvars> -destroy -disable_prompt
```
