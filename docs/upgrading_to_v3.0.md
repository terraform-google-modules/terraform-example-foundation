# Upgrade Guidance

Before moving forward with adopting components of v3, please review the list of breaking changes below. You can find a list of all changes in the [Changelog]()

**Note:** There is no in-place upgrade path from v2 to v3

## Major Breaking Changes 

- Upgrade minimum required Terraform version to 1.3.0
- Creating Remote State
- Diferent Service Accoutns
- Configure bring your own Service Account
- 3-Networks split into two
- 4-projects, infra pipeline not longer creating Docker Image

- Other Critical features

## Steps to upgrade codebase

In order to upgrade foundation's codebase you will need to merge newer changes from v3 into your local repository and then run `terraform apply`.

It is up to you to decide whether you update the whole project or some parts of it. However, newer features might require entire code blocks to be upgraded simultaneously. This is why we highly recommend you review outputs from `terraform plan` before applying any changes.

For this migration you will encounter two scenarios which we describe as following:

1. If you have already forked v2 in your private repository, you can manually merge changes from v3 into your modified version of v2

2. If you have not made modifications to v2, you can upgrade the fork to v3

You should follow the one that is most appropriate to you

**Important:** Expect resources to be deleted and recreated when you run `terraform apply`. You can avoid this behavior using [move blocks](https://developer.hashicorp.com/terraform/tutorials/configuration-language/move-config) functionality from Terraform. We will talk more about this in following section.

## Migration w/o recreation

As stated earlier, migrating foundation's configuration to newer versions might end with some resources being recreated (destroyed and created) due to some configuration blocks being moved from their initial modules.

You can avoid this behavior with *move blocks*. These blocks tell terraform where the resources have been moved to and updates the terraform state with new configuration without triggering resource recreation.

### 0-bootstrap example

Consider a 0-bootstrap foundation v2 deployment without no modifications. If we try to migrate to v3 we will the following as the summarize of the output of `terraform plan`.

    Plan: 165 to add, 2 to change, 67 to destroy.

You can review `module.cloudbuild_bootstrap.module.cloudbuild_project` module and observe that there are plenty of resources that are destroyed and created again in a similar module.

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

We can omit this behavior if we provide following block.

    # cloudbuild bootstrap
    moved {
        from = module.cloudbuild_bootstrap.module.cloudbuild_project
        to   = module.tf_source.module.cloudbuild_project
    }

Now, we can verify that the number of resources to be destroyed have been reduced considerably.

    Plan: 146 to add, 4 to change, 48 to destroy.

**Note:** In order to obtain similar results as presented before you will also need to hard-code CICD project's ID at `module.tf_source`.

You can review some examples of other moved blocks in the provided `moved.tf.example`

## Backups

You can save resources from being destroyed and instead make a copy of them as a backup.

The following blocks of code shows how to save KMS keys no longer being part of the foundation v3 configuration.

```hcl
resource "google_kms_crypto_key" "backup_tf_key" {
    destroy_scheduled_duration = "86400s"
    import_only                   = false
    key_ring                      = "projects/prj-b-cicd-9aee/locations/us-central1/keyRings/tf-keyring"
    labels                        = {}
    name                          = "tf-key"
    purpose                       = "ENCRYPT_DECRYPT"
    skip_initial_version_creation = false

    version_template {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
    }
}
```

asdf



    resource "google_kms_key_ring" "backup_tf_keyring" {
        location = "us-central1"
        name     = "tf-keyring"
        project  = "prj-b-cicd-9aee"
    }

    moved {
        from = module.cloudbuild_bootstrap.google_kms_crypto_key.tf_key
        to   = google_kms_crypto_key.backup_tf_key
    }

    moved {
        from = module.cloudbuild_bootstrap.google_kms_key_ring.tf_keyring
        to   = google_kms_key_ring.backup_tf_keyring
    }

Backup resources can be put inside the provided `backup.tf.example` file.

## Resource Changes

