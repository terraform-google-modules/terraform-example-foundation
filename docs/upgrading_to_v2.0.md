# Upgrade Guidance

Before moving forward with adopting components of V2, please review the list of
breaking changes below. You can find a list of all changes in the
[Changelog](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/CHANGELOG.md).

Note: There is no in-place upgrade path from v1 to v2.

## Breaking Changes

-  The repo now requires Terraform version 0.13 (minimum). For v1 the minimum version was
   0.12.x.
-  V2 introduces a new alternative hub-and-spoke network architecture,
   described in Section 7.2 of the blueprint. The Terraform to build the
   hub-and-spoke network are located in 1-org and 3-networks.
-  In V2, the infrastructure pipeline has transitioned from using Google
   Container Registry (GCR) to using Google Artifact Registry. Artifact
   Registry extends the capabilities of GCR as outlined
   [here](https://cloud.google.com/artifact-registry/docs/transition/transition-from-gcr#compare).
   The Terraform can be found in 4-projects, within the infra_pipeline module.
-  Normal FW rules > Hierarchical FW rules (functionality is the same,
   construct is different)

## Steps to upgrade codebase

Note: When you run `terraform apply`, expect resources to be deleted and recreated. Be sure
 to monitor errors during the `terrform apply` process.

1. If you have already forked V1 in your private repository, you can
   manually merge changes from V2 into your modified version of V1.
1. If you have not made modifications to V1, you can upgrade the existing
   fork to V2
