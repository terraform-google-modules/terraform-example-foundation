# Contributing

This document provides guidelines for contributing to the module.

## Dependencies

The following dependencies must be installed on the development system:

- [Docker Engine][docker-engine]
- [Google Cloud SDK][google-cloud-sdk]
- [make]

## Generating Documentation for Inputs and Outputs

The Inputs and Outputs tables in the READMEs of the root module,
submodules, and example modules are automatically generated based on
the `variables` and `outputs` of the respective modules. These tables
must be refreshed if the module interfaces are changed.

### Execution

Run `make generate_docs` to generate new Inputs and Outputs tables.


## Integration Testing

Integration tests are used to verify the behaviour of each stage in this repo.
Additions, changes, and fixes should be accompanied with tests.

The integration tests are run using [Kitchen][kitchen],
[Kitchen-Terraform][kitchen-terraform], and [InSpec][inspec]. These
tools are packaged within a Docker image for convenience.

Six test-kitchen instances are defined and should be executed in serial order:

- `bootstrap`
- `org`
- `envs`
- `shared`
- `networks`
- `projects`


### Test Environment
The easiest way to test the repo is in an isolated folder. The setup for such a project is defined in [test/setup](./test/setup/) directory.

To use this setup, you need a service account with Organization Admin access within an organization. Export the Service Account credentials to your environment like so:

```
export SERVICE_ACCOUNT_JSON=$(< credentials.json)
```

You will also need to set a few environment variables:
```
export TF_VAR_org_id="your_org_id"
export TF_VAR_folder_id="your_folder_id"
export TF_VAR_billing_account="your_billing_account_id"
export TF_VAR_folder_id="your_test_folder"
export TF_VAR_group_email="your_group_email"
```

With these settings in place, you can prepare a test project using Docker:
```
make docker_test_prepare
```

### Test Execution

1. Run `make docker_run` to start the testing Docker container in
   interactive mode.

1. Run `kitchen_do create <STAGE_NAME>` to initialize the working
   directory for the stage.

1. Run `kitchen_do converge <STAGE_NAME>` to apply the stage.

1. Run `kitchen_do verify <STAGE_NAME>` to test the resources created in the current stage.

Destruction of resources should be done in the reverse order of creation.

1. Run `kitchen_do destroy <STAGE_NAME>` to destroy the stage.


## Linting and Formatting

Many of the files in the repository can be linted or formatted to
maintain a standard of quality.

### Execution

Run `make docker_test_lint`.

[docker-engine]: https://www.docker.com/products/docker-engine
[flake8]: http://flake8.pycqa.org/en/latest/
[gofmt]: https://golang.org/cmd/gofmt/
[google-cloud-sdk]: https://cloud.google.com/sdk/install
[hadolint]: https://github.com/hadolint/hadolint
[inspec]: https://inspec.io/
[kitchen-terraform]: https://github.com/newcontext-oss/kitchen-terraform
[kitchen]: https://kitchen.ci/
[make]: https://en.wikipedia.org/wiki/Make_(software)
[shellcheck]: https://www.shellcheck.net/
[terraform-docs]: https://github.com/segmentio/terraform-docs
[terraform]: https://terraform.io/
