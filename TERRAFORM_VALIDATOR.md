# terraform-validator configuration

These are instruction to configure [terraform-validator](https://github.com/GoogleCloudPlatform/terraform-validator) in CI/CD for the example foundation.

These instructions consider that you have cloned `terraform-example-foundation` repo locally and had already configured the private repos for `gcp-org`, `gcp-environments`, `gcp-networks` and `gcp-projects`.

## Run terraform-validator with tf-wrapper.sh script manually

The user running terraform-validator must have at least these roles to run terraform-validator:

- **Browser** - `roles/browser`
- **Security Reviewer** - `roles/iam.securityReviewer`

Installation steps:

1. Install terraform-validator locally
    1. Follow the instructions on the terraform-validator [user guide](https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator) to download the latest version.
    1. Rename `terraform-validator-linux-amd64` to `terraform-validator`
    1. Update permissions `chmod +x terraform-validator`
    1. Move terraform-validator binary to a folder in your PATH, like for example `$HOME/.local/bin`
1. Outside of your clone of terraform-example-foundation repo clone the policy repo `git clone https://github.com/forseti-security/policy-library.git`
1. Export the path to the policy repo `export policy_library_path=$(pwd)/policy-library`
1. Change into one of you private repos like `gcp-org`
1. Run terraform-validator
    1. Run `./tf-wrapper.sh init prod`
    1. Run `./tf-wrapper.sh plan prod`
    1. Run `./tf-wrapper.sh validate  prod ${policy_library_path}`

You should get a result like this:

```
*************** TERRAFORM VALIDATE ******************
      At environment: envs/shared
      Using policy from: /home/foo/policy-library
*****************************************************
ERROR: logging before flag.Parse: I0728 23:16:46.428406    3913 validator.go:177] starting 2 workers
ERROR: logging before flag.Parse: I0728 23:16:46.428862    3913 validator.go:186] worker 0 starting
ERROR: logging before flag.Parse: I0728 23:16:46.430272    3913 validator.go:186] worker 1 starting
No violations found.
```

## Run terraform-validator in Cloud Build

Configuration steps:

1. The cloud build service account will need at least these roles to run terraform-validator:
   - **Browser** - `roles/browser`
   - **Security Reviewer** - `roles/iam.securityReviewer`
1. Follow the instructions in [configure access for cloud build service account](https://cloud.google.com/cloud-build/docs/securing-builds/configure-access-for-cloud-build-service-account) to grant these roles.
1. terraform-validator is already installed in the image used in cloud build.
1. Open `https://console.cloud.google.com/cloud-build/triggers?project=YOUR_CLOUD_BUILD_PROJECT_ID` (this is from terraform output from 0-bootstrap section)
1. Edit to each one of your Cloud build triggers and add a new Substitution variable with variable `_POLICY_REPO` and value `/workspace/policy-library`.
1. Outside of your clone of terraform-example-foundation repo clone the policy repo `git clone https://github.com/forseti-security/policy-library.git`
1. change in to `policy-library` and run `git archive -o ../policy-library.zip master`
1. change out of `policy-library` and change in one of your private repos like `gcp-org`
    1. Checkout one of your branches like plan `git checkout plan`
    1. run `unzip -qo ../policy-library.zip -d policy-library`
    1. Commit changes with `git add .` and `git commit -m 'Your message'`
    1. push your change `git push plan`.
1. Open `https://console.cloud.google.com/cloud-build/builds?project=YOUR_CLOUD_BUILD_PROJECT_ID` and check the build you just triggered.
1. Repeat these steps for every branch of every private repo you created.

## Run terraform-validator in Jenkins

TBD
