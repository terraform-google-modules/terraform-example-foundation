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

Run `make docker_generate_docs` to generate new Inputs and Outputs tables.

## Integration Testing

Integration tests are used to verify the behavior of each stage in this repo.
Additions, changes, and fixes should be accompanied with tests.

The integration tests are run using the [Blueprint test][blueprint-test] framework. The framework is packaged within a Docker image for convenience.

Eight Blueprint tests are defined and should be executed in serial order:

- `bootstrap`
- `org`
- `envs`
- `shared`
- `networks`
- `projects-shared`
- `projects`
- `app-infra`

### Test Environment

The easiest way to test the repo is in an isolated folder. The setup for such a project is defined in [test/setup](./test/setup/) directory.

To use this setup, you need a service account with:

- Organization Admin access within an organization.
- Folder Creator and Project Creator within a folder/organization.
- Billing Account Administrator on a billing account

Export the Service Account credentials to your environment like so:

```bash
export SERVICE_ACCOUNT_JSON=$(< credentials.json)
```

You will also need to set a few environment variables:

```bash
export TF_VAR_org_id="your_org_id"
export TF_VAR_folder_id="your_folder_id"
export TF_VAR_billing_account="your_billing_account_id"
export TF_VAR_group_email="your_group_email"
export TF_VAR_domain_to_allow="your_test_domain"
export TF_VAR_example_foundations_mode="your_network_mode(base|HubAndSpoke)"
```

With these settings in place, you can prepare a test project using Docker:

```bash
make docker_test_prepare
```

### Test Execution

1. Run `make docker_run` to start the testing Docker container in
   interactive mode.

1. Run `cd test/integration` to go to the integration test directory.

1. Run `cft test list --test-dir /workspace/test/integration` to list the available test.

1. Run `cft test run <TEST_NAME> --stage init --verbose --test-dir /workspace/test/integration` to initialize the working
   directory for the stage.

1. Run `cft test run <TEST_NAME> --stage apply --verbose --test-dir /workspace/test/integration` to apply the stage.

1. Run `cft test run <TEST_NAME> --stage verify --verbose --test-dir /workspace/test/integration` to test the resources created in the current stage.

Destruction of resources should be done in the reverse order of creation.

1. Run `cft test run <TEST_NAME> --stage destroy --verbose --test-dir /workspace/test/integration` to destroy the stage.

## Linting and Formatting

Many of the files in the repository can be linted or formatted to
maintain a standard of quality.

### Execution

Run `make docker_test_lint` to list lint issues.

Use Terraform command [fmt] to format terraform code.

Use [gofmt] to format Go code.

[docker-engine]: https://www.docker.com/products/docker-engine
[flake8]: https://flake8.pycqa.org/en/latest/
[fmt]: https://www.terraform.io/cli/commands/fmt
[gofmt]: https://golang.org/cmd/gofmt/
[google-cloud-sdk]: https://cloud.google.com/sdk/install
[hadolint]: https://github.com/hadolint/hadolint
[make]: https://en.wikipedia.org/wiki/Make_(software)
[shellcheck]: https://www.shellcheck.net/
[terraform-docs]: https://github.com/segmentio/terraform-docs
[terraform]: https://terraform.io/
[blueprint-test]: https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/tree/master/infra/blueprint-test
