# Troubleshooting

## Terminology

See [GLOSSARY.md](./GLOSSARY.md).

- - -

## Problems

- [Common issues](#common-issues)
- [Caller does not have permission in the Organization](#caller-does-not-have-permission-in-the-organization)
- [Billing quota exceeded](#billing-quota-exceeded)
- [Terraform Error acquiring the state lock](#terraform-error-acquiring-the-state-lock)

- - -

## Common issues

- [Project quota exceeded](#project-quota-exceeded)
- [Default branch setting](#default-branch-setting)
- [Terraform State Snapshot lock](#terraform-state-snapshot-lock)
- [Application authenticated using end user credentials](#application-authenticated-using-end-user-credentials)
- [Cannot assign requested address error in Cloud Shell](#cannot-assign-requested-address-error-in-cloud-shell)
- [Error: Unsupported attribute](#error-unsupported-attribute)
- [Error: Error adding network peering](#error-error-adding-network-peering)
- [Error: Terraform deploy fails due to GitLab repositories not found](#terraform-deploy-fails-due-to-gitlab-repositories-not-found)
- [Error: Gitlab pipelines access denied](#gitlab-pipelines-access-denied)
- [Error: Unknown project id on 4-project step context](#error-unknown-project-id-on-4-project-step-context)
- [Error: Error getting operation for committing purpose for TagValue](#error-error-getting-operation-for-committing-purpose-for-tagvalue)
- - -

### Project quota exceeded

**Error message:**

```text
Error code 8, message: The project cannot be created because you have exceeded your allotted project quota
```

**Cause:**

This message means you have reached your [project creation quota](https://support.google.com/cloud/answer/6330231).

**Solution:**

In this case, you can use the [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase)
form to request a quota increase.

In the support form,
for the field **Email addresses that will be used to create projects**,
use the email address of `projects_step_terraform_service_account_email` that is created by the Terraform Example Foundation 0-bootstrap step.

**Notes:**

- If you see other quota errors, see the [Quota documentation](https://cloud.google.com/docs/quota).

### Default branch setting

**Error message:**

```text
error: src refspec master does not match any
```

**Cause:**

This could be due to init.defaultBranch being set to something other than
`main`.

**Solution:**

1. Determine your default branch:

   ```bash
   git config init.defaultBranch
   ```

   Outputs `main` if you are in the main branch.
1. If your default branch is not set to `main`, set it:

   ```bash
   git config --global init.defaultBranch main
   ```

### Terraform State Snapshot lock

**Error message:**

When running the build for the branch `production` in step 3-networks in your **Foundation CI/CD Pipeline** the build fails with:

```
state snapshot was created by Terraform v1.x.x, which is newer than current v1.5.7; upgrade to Terraform v1.x.x or greater to work with this state
```

**Cause:**

The manual deploy step for the shared environment in [3-networks](../3-networks#deploying-with-cloud-build) was executed with a Terraform version newer than version v1.5.7 used in the **Foundation CI/CD Pipeline**.

**Solution:**

You have two options:

#### Downgrade your local Terraform version

You will need to re-run the deploy of the 3-networks shared environment with Terraform v1.5.7.

Steps:

- Go to folder `gcp-networks/envs/shared/`.
- Update `backend.tf` with your bucket name from the 0-bootstrap step.
- Run `terraform destroy` in the folder using the Terraform v1.x.x version.
- Delete the Terraform state file in `gs://YOUR-TF-STATE-BUCKET/terraform/networks/envs/shared/default.tfstate`. This bucket is in your **Seed Project**.
- Install Terraform v1.5.7.
- Re-run the manual deploy of 3-networks shared environment using Terraform v1.5.7.

#### Upgrade your 0-bootstrap runner image Terraform version

Replace `1.x.x` with the actual version of your local Terraform version in the following instructions:

- Go to folder `0-bootstrap`.
- Edit the local `terraform_version` in the Terraform [cb.tf](../0-bootstrap/cb.tf) file:
  - Upgrade local `terraform_version` from `"1.5.7"` to `"1.x.x"`
- Run `terraform init`.
- Run `terraform plan` and review the output.
- Run `terraform apply`.

### Application authenticated using end user credentials

**Error message:**

When running `gcloud` commands in Cloud Shell like

```bash
gcloud scc notifications describe <scc_notification_name> --organization YOUR_ORGANIZATION_ID
```

or

```bash
gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"
```

you receive the error:

```text
Error 403: Your application has authenticated using end user credentials from the Google Cloud SDK or Google Cloud Shell which are not supported by the X.googleapis.com.
We recommend configuring the billing/quota_project setting in gcloud or using a service account through the auth/impersonate_service_account setting.
For more information about service accounts and how to use them in your application, see https://cloud.google.com/docs/authentication/.
```

**Cause:**

When using application default credentials in Cloud Shell a billing project is not available for APIs like `securitycenter.googleapis.com` or `accesscontextmanager.googleapis.com`.

**Solution:**

you can re-run the command using impersonation or providing a billing project:

- Impersonate the Terraform Service Account

```bash
--impersonate-service-account=terraform-org-sa@<SEED_PROJECT_ID>.iam.gserviceaccount.com
```

- Provide a billing project

```bash
--billing-project=<A-VALID-PROJECT-ID>
```

If you provide a billing project, you must have the `serviceusage.services.use` permission on the billing_project.

### Cannot assign requested address error in Cloud Shell

**Error message:**

When using [Google Cloud Shell](https://cloud.google.com/shell/docs) to deploy the code in ths repository, you may face an error like

```text
dial tcp [2607:f8b0:400c:c15::5f]:443: connect: cannot assign requested address
```

when Terraform calls the Google APIs.

**Cause:**

This is a [known terraform issue](https://github.com/hashicorp/terraform-provider-google/issues/6782) regrading IPv6.

**Solution:**

At this time the alternatives are:

1. To use a [workaround](https://stackoverflow.com/a/62827358) to force Google API calls in Cloud Shell to use an IP from the `private.googleapis.com` range (199.36.153.8/30 ) or
1. To deploy the foundation code from a local machine that supports IPv6.

If you use the workaround, the API list should include the ones that are [allowed](../policy-library/policies/constraints/serviceusage_allow_basic_apis.yaml) in the terraform-example-foundation policy library.

### Error: Unsupported attribute

**Error message:**

```text
Error: Unsupported attribute

  on main.tf line 22, in locals:
  22:   org_id               = data.terraform_remote_state.bootstrap.outputs.common_config.org_id
    ├────────────────
    │ data.terraform_remote_state.bootstrap.outputs is object with no attributes

This object does not have an attribute named "common_config".
```

**Cause:**

The stages after `0-bootstrap` use `terraform_remote_state` data source to read common configuration like the organization ID from the output of the `0-bootstrap` stage.
The error means that the Terraform state of the `0-bootstrap` stage was not copied to the Terraform state bucket created in stage `0-bootstrap`.

**Solution:**

Follow the instructions at the end of the [Deploying with Cloud Build](../0-bootstrap/README.md#deploying-with-cloud-build) section in the `0-bootstrap` README to copy the Terraform state to the Cloud Storage bucket created in stage `0-bootstrap` and retry planning/applying the stage you are deploying.

### Error: Error adding network peering

**Error message:**

```text
Error: Error adding network peering: googleapi: Error 403: Rate Limit Exceeded
Details:
[
  {
    "@type": "type.googleapis.com/google.rpc.ErrorInfo",
    "domain": "compute.googleapis.com",
    "metadatas": {
      "containerId": "76352966089",
      "containerType": "PROJECT",
      "location": "global"
    },
    "reason": "CONCURRENT_OPERATIONS_QUOTA_EXCEEDED"
  }
]
, rateLimitExceeded

```

**Cause:**

In a deploy using the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) network mode, an error occurs when adding the network peering between the restricted Hub network and the restricted Spoke network or the base Hub network and the base Spoke network due to too many peering operations.

**Solution:**

This is a transient error and the deploy can be retried. Wait for at least a minute and retry the deploy.


### Error: Unknown project id on 4-project step context

**Error message:**

```text
Error 400: Unknown project id: 'prj-<business-unity>-<environment>-sample-base-<random-suffix>', invalid
```

**Cause:**

When you try to run 4-projects step without requesting additional project quota for **project service account created in 0-bootstrap step** you may face the error above, even after the project quota issue is resolved, due to an inconsistency in terraform state.

**Solution:**

- Make sure you [have requested the additional project quota](#project-quota-exceeded) for the **project SA e-mail** before running the following steps.

You will need to mark some Terraform resources as **tainted** in order to trigger the recreation of the missing projects to fix the inconsistent in the terraform state.

1. In a terminal, navigate to the path where the error is being reported.

   For example, if the unknown project ID is `prj-bu1-p-sample-base-shared`, you should go to ./gcp-projects/business_unit_1/production (`business_unit_1` due to `bu1` and `production` due to `p`, see [naming conventions](https://cloud.google.com/architecture/security-foundations/using-example-terraform#naming_conventions) for more information on the projects naming guideline).

   ```bash
   cd ./gcp-projects/<business_unit>/<environment>
   ```

1. Run the `terraform init` command so you can pull the remote state.

   ```bash
   terraform init
   ```

1. Run the `terraform state list` command, filtering by `random_project_id_suffix`.
This command will give you all the expected projects that should be created for this BU and environment that uses a random suffix.

   ```bash
   terraform state list | grep random_project_id_suffix
   ```

1. Identify the folder which is the parent of the projects of the environment.
If the Terraform Example Foundation is deployed directly under the organization use `--organization`, if the Terraform Example Foundation is deployed under a folder use `--folder`. The "ORGANIZATION_ID" and "PARENT_FOLDER" are the input values provided for the 0-bootstrap step.

   ```bash
   gcloud resource-manager folders list [ --organization=ORGANIZATION_ID ][ --folder=PARENT_FOLDER ]
   ```

1. The result of the `gcloud` command will look like the following output.
Using the `production` environment for this example, the folder ID for the environment would be `333333333333`.

   ```
   DISPLAY_NAME         PARENT_NAME                     ID
   fldr-bootstrap       folders/PARENT_FOLDER  111111111111
   fldr-common          folders/PARENT_FOLDER  222222222222
   fldr-production      folders/PARENT_FOLDER  333333333333
   fldr-nonproduction  folders/PARENT_FOLDER  444444444444
   fldr-development     folders/PARENT_FOLDER  555555555555
   ```

1. Run the `gcloud projects list` command to.
Replace `id_of_the_environment_folder` with the proper ID of the folder retrieved in the previous step.
This command will give you all the projects that were actually created.

   ```bash
   gcloud projects list --filter="parent=<id_of_the_environment_folder>"
   ```

1. For each resource listed in the `terraform state` step for a project that is **not** returned by the `gcloud projects list` step, we should mark that resource as tainted to force it to be recreated in order to fix the inconsistency in the terraform state.

   ```bash
   terraform taint <resource>[index]
   ```

   For example, in the following command we are marking as tainted the env secrets project. You may need to run the `terraform taint` command multiple times, depending on how many missing projects you have.

   ```bash
   terraform taint module.env.module.env_secrets_project.module.project.module.project-factory.random_string.random_project_id_suffix[0]
   ```

1. After running the `terraform taint` command for all the non-matching items, go to Cloud Build and trigger a retry action for the failed job.
This should complete successfully, if you encounter another similar error for another BU/environment that will require you to follow this guide again but instead changing paths according to the BU/environment reported in the error log.

**Notes:**

   - Make sure you run the taint command just for the resources that contain the [number] at the end of the line returned by terraform state list step. You don't need to run for the groups (the resources that don't have the [] at the end).

### Error: Error getting operation for committing purpose for TagValue

**Error message:**

```text
Error: Error waiting to create TagValue: Error waiting for Creating TagValue: Error code 13, message: Error getting operation for committing purpose for TagValue: tagValues/{tag_value_id}
```

**Cause:**

Sometimes when deploying a [google_tags_tag_value](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_value) the error occurs and Terraform is not able to finish the execution.

**Solution:**

1. This is a transient error and the deploy can be retried.
1. A retry policy was added to prevent this error during the integration test.
- - -

### Caller does not have permission in the Organization

**Error message:**

```text
Error: Error when reading or editing Organization Not Found : <organization-id>: googleapi: Error 403: The caller does not have permission, forbidden
```

**Cause:**

User running Terraform is missing [Organization Administrator](https://cloud.google.com/iam/docs/understanding-roles#resource-manager-roles) predefined role at the Organization level.

**Solution:**

- If the user **does not have the role Organization Administrator** try the following:

You will need to request the roles to be granted to your user by your organization administration team.

- If the user **does have the role Organization Administrator** try the following:

```bash
gcloud auth application-default login
gcloud auth list # <- confirm that correct account has a star next to it
```

Re-run `terraform` after.

### Billing quota exceeded

**Error message:**

```text
Error: Error setting billing account "XXXXXX-XXXXXX-XXXXXX" for project "projects/some-project": googleapi: Error 400: Precondition check failed., failedPrecondition
```

**Cause:**

Most likely this is related to a billing quota issue.

**Solution:**

try

```bash
gcloud alpha billing projects link projects/some-project --billing-account XXXXXX-XXXXXX-XXXXXX
```

If output states `Cloud billing quota exceeded`, you can use the [Request Billing Quota Increase](https://support.google.com/code/contact/billing_quota_increase) form to request a billing quota increase.

### Terraform Error acquiring the state lock

**Error message:**

```text
Error: Error acquiring the state lock
```

**Cause:**

This message means that you are trying to apply a Terraform configuration with a remote backend that is in a [locked state](https://www.terraform.io/language/state/locking).

If the Terraform process was unable to finish due to an unexpected event, i.e build timeout or terraform process killed. It will keep the Terraform State **locked**.

**Solution:**

The following commands are an example of how to unlock the **development environment** from step 2-environments that is one part of the Foundation Example.
It can also be applied in the same way to the other parts.

1. Clone the repository where you got the Terraform State lock. The following example assumes **development environment** from step 2-environments:

   ```bash
   gcloud source repos clone gcp-environments --project=YOUR_CLOUD_BUILD_PROJECT_ID
   ```

1. Navigate into the repo and change to the development branch:

   ```bash
   cd gcp-environments
   git checkout development
   ```

1. If your project does not have a remote backend you can jump skip the next 2 commands and jump to `terraform init` command.
1. If your project has a remote backend you will have to update `backend.tf` with the remote state backend bucket.
You can get this information from step `0-bootstrap` by running the following command:

   ```bash
   terraform output gcs_bucket_tfstate
   ```

1. Update `backend.tf` with the remote state backend bucket you got on previously inside `<YOUR-REMOTE-STATE-BACKEND-BUCKET>`:

   ```bash
   for i in `find . -name 'backend.tf'`; do sed -i'' -e 's/UPDATE_ME/<YOUR-REMOTE-STATE-BACKEND-BUCKET>/' $i; done
   ```

1. Navigate into `envs/development` where your terraform config files are in and run terraform init:

   ```bash
   cd envs/development
   terraform init
   ```

1. At this point, you will be able to get Terraform State lock information and unlock your state.
1. After running terraform apply you should get an error message like the following:

   ```text
   terraform apply
   Acquiring state lock. This may take a few moments...
   ╷
   │ Error: Error acquiring the state lock
   │
   │ Error message: writing "gs://<YOUR-REMOTE-STATE-BACKEND-BUCKET>/<PATH-TO-TERRAFORM-STATE>/<tf state file name>.tflock" failed: googleapi: Error 412: At least one
   │ of the pre-conditions you specified did not hold., conditionNotMet
   │ Lock Info:
   │   ID:        1664568683005669
   │   Path:      gs://<YOUR-REMOTE-STATE-BACKEND-BUCKET>/<PATH-TO-TERRAFORM-STATE>/<tf state file name>.tflock
   │   Operation: OperationTypeApply
   │   Who:       user@domain
   │   Version:   1.0.0
   │   Created:   2022-09-30 20:11:22.90644727 +0000 UTC
   │   Info:
   │
   │
   │ Terraform acquires a state lock to protect the state from being written
   │ by multiple users at the same time. Please resolve the issue above and try
   │ again. For most commands, you can disable locking with the "-lock=false"
   │ flag, but this is not recommended.
   ```

1. With the lock `ID` you will be able to remove the Terraform State lock using `terraform force-unlock` command. It is a **strong recommendation** to review the official documentation regarding [terraform force-unlock](https://www.terraform.io/language/state/locking#force-unlock) command before executing it.
1. After unlocking the Terraform State you will be able to execute a `terraform plan` for review of the state. The following links can help you to recover the Terraform State for your configuration and move on:
    1. [Manipulating Terraform State](https://developer.hashicorp.com/terraform/cli/state)
    1. [Moving Resources](https://developer.hashicorp.com/terraform/cli/state/move)
    1. [Importing Infrastructure](https://developer.hashicorp.com/terraform/cli/import)

**Terraform State lock possible causes:**

- If you realize that the Terraform State lock was due to a build timeout increase the build timeout on [build configuration](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/build/cloudbuild-tf-apply.yaml#L15).

### Terraform deploy fails due to GitLab repositories not found

**Error message:**

```text
Error: POST https://gitlab.com/api/v4/projects/<GITLAB-ACCOUNT>/<GITLAB-REPOSITORY>/variables: 404 {message: 404 Project Not Found}

```

**Cause:**

This message means that you are using a wrong Access Token or you have Access Token created in both Gitlab Account/Group and GitLab Repository.

Only Personal Access Token under GitLab Account/Group should exist.

**Solution:**

Remove any Access Token from the GitLab repositories used by Google Secure Foundation Blueprint.

### Gitlab pipelines access denied

**Error message:**

From the logs of your Pipeline job:

```text
Error response from daemon: pull access denied for registry.gitlab.com/<YOUR-GITLAB-ACCOUNT>/<YOUR-GITLAB-CICD-REPO>/terraform-gcloud, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
```

**Cause:**

The cause of this message is that the CI/CD repository has "Limit access to this project" enabled in the Token Access settings.

**Solution:**

Add all the projects/repositories to be used in the Terraform Example Foundation to the allow list available in
`CI/CD Repo -> Settings -> CI/CD -> Token Access -> Allow CI job tokens from the following projects to access this project`.
