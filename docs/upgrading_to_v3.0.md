# Upgrade Guidance
Before moving forward with adopting components of v3 review the list of breaking changes below. You can find a complete list of features, bug fixes and other updates in the [Changelog](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/CHANGELOG.md).

**Important:** There is no in-place upgrade path from v2 to v3.

## Breaking Changes

- Upgrade minimum required Terraform version to 1.3.0, previously was 0.13.7.
- Added usage of Remote State data. This feature centralizes terraform variables that are input through all steps in a remote state in 0-bootstrap step. This uses a Google Storage bucket so that you will not have the need to re-declare them while deploying the foundation example. Note that each step requires `read/write` access to this bucket in order to be properly deployed.
- Added Granular Service Account (SA). In previous versions, only one SAs were used to deploy all steps, this ended up having an excess of permissions given to them. Now, each step has its own SA with very limited permissions.
- User-specified service accounts in Cloud Build (Bring your Service Account - BYOSA). Using user-specified service accounts in Cloud Build instead of the default Cloud Build service account enables you to grant different permissions to these service accounts depending on the tasks they perform. For more details, see following [link](https://cloud.google.com/build/docs/securing-builds/configure-user-specified-service-accounts).
- 3-networks directory split into two different directories. The 3-Networks step supported both network modes, Dual Shared VPC and Hub and Spoke. In this release, these two modes have been separated into two different implementations.

**Note:** You can use newer Terraform versions directly on top of already deployed configurations that use older versions. However, note that doing so will prevent you from using these older versions. Also, this will update terraform state and dependencies (external modules and provider's resources). Thus, we recommend to backup your current terraform state before trying to upgrade your codebase.

## Integrating New Features

As stated earlier, there is no direct path for upgrading example foundation codebase. Thus, we discourage trying this by solely applying foundation v3's code (i.e. running `terraform apply` on new code).

In case you require to integrate some of the v3's features, we recommend to review the documentation regarding the feature you are interested in and use v3's code as a guidance for its implementation. We also recommend to deeply review the output from `terraform plan` before applying the updates.

**Note:** You must verify that you are using the correct version for `terraform` and `gcloud`. You can check these and other additional requirements using this [validate script](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/scripts/validate-requirements.sh).

### Move Blocks

Integrating features to your codebase can end up with some resources being moved from a parent module to a child module, from a child module to a parent module or even taken out from an external module to your configuration.

Given this variety of scenarios, we suggest you to consider `moved blocks` which enables you to update your resources and safely refactor your code. For more details, see [moved blocks](https://developer.hashicorp.com/terraform/tutorials/configuration-language/move-config).

**Note:** `moved blocks` are supported by the required terraform version for example foundation v3 (v1.3.0).

Next, we give some examples on how these moved blocks can be implemented.

### Module-to-Module

Consider a 0-bootstrap foundation v2 deployment without no modifications. If you try to migrate to v3 you will observe the following as the summarize for the output of `terraform plan`.

    Plan: 165 to add, 2 to change, 67 to destroy.

You can review `module.cloudbuild_bootstrap.module.cloudbuild_project` module and observe that there are plenty of resources related to it that are destroyed and created again in a different module.

    # module.cloudbuild_bootstrap.module.cloudbuild_project.module.project-factory.module.project_services.google_project_service.project_services["admin.googleapis.com"] will be destroyed
    # (because google_project_service.project_services is not in configuration)
    - resource "google_project_service" "project_services" {
      - disable_dependent_services = true -> null
      - disable_on_destroy         = false -> null
      - id                         = "prj-b-cicd-9aee/admin.googleapis.com" -> null
      - project                    = "prj-b-cicd-9aee" -> null
      - service                    = "admin.googleapis.com" -> null
    }

And

    # module.tf_source.module.cloudbuild_project.module.project-factory.module.project_services.google_project_service.project_services["admin.googleapis.com"] will be created
    + resource "google_project_service" "project_services" {
      + disable_dependent_services = true
      + disable_on_destroy         = false
      + id                         = (known after apply)
      + project                    = (known after apply)
      + service                    = "admin.googleapis.com"
    }

In this case, we can instruct terraform to safely move this resource if we provide following block of code.

    # cloudbuild bootstrap
    moved {
        from = module.cloudbuild_bootstrap.module.cloudbuild_project
        to   = module.tf_source.module.cloudbuild_project
    }

**Note:** This code can be implemented in a separate *terraform file* (e.g. moved.tf).

In most cases, this is enough to update your terraform configuration. However, in this particular example, the source module's ID is composed of an autogenerated random string, so you will need to hardcode this module's ID in the updated resource, as well.

    module "tf_source" {
        source  = "terraform-google-modules/bootstrap/google//modules/tf_cloudbuild_source"
        version = "~> 6.2"

        org_id                = var.org_id
        folder_id             = google_folder.bootstrap.id
        project_id            = "${var.project_prefix}-b-cicd-${random_string.suffix.result}" # REPLACE_HERE
        billing_account       = var.billing_account
        group_org_admins      = local.group_org_admins
        buckets_force_destroy = var.bucket_force_destroy
    ...
    }

You can verify that the number of resources to be destroyed has been reduced.

    Plan: 146 to add, 4 to change, 48 to destroy.
### Backups

You can also use `moved blocks` to save resources from being destroyed and instead make a copy of them as a backup.

The following blocks of code shows how to save KMS keys that  are no longer being part of the configuration for foundation v3.

```hcl
terraform-example foundation/0-bootstrap/backup.tf.example

resource "google_kms_crypto_key" "backup_tf_key" {
    destroy_scheduled_duration = "86400s"
    import_only                   = false
    key_ring                      = "projects/<PROJECT_ID>/locations/us-central1/keyRings/tf-keyring"
    labels                        = {}
    name                          = "tf-key"
    purpose                       = "ENCRYPT_DECRYPT"
    skip_initial_version_creation = false

    version_template {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
    }
}

resource "google_kms_key_ring" "backup_tf_keyring" {
    location = "us-central1"
    name     = "tf-keyring"
    project  = <PROJECT_ID>
}
```

```hcl
terraform-example foundation/0-bootstrap/moved.tf.exmaple

moved {
    from = module.cloudbuild_bootstrap.google_kms_crypto_key.tf_key
    to   = google_kms_crypto_key.backup_tf_key
}

moved {
    from = module.cloudbuild_bootstrap.google_kms_key_ring.tf_keyring
    to   = google_kms_key_ring.backup_tf_keyring
}
```
