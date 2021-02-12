# Terraform cloud builder

This builder creates a [Terraform](https://www.terraform.io/) image for use in cloud build to run the [Cloud Foundation Toolkit](https://cloud.google.com/foundation-toolkit/) modules.

### Building this builder
This builder is automatically created if you use the cloudbuild terraform submodule. If you would like to build manually, run the following command in this directory.
```sh
$ gcloud builds submit --config=cloudbuild.yaml
```
