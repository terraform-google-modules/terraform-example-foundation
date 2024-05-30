# Upgrade Guidance
Before moving forward with adopting components of v4, review the list of breaking changes below. You can find a complete list of features, bug fixes and other updates in the [Changelog](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/CHANGELOG.md).

**Important:** There is no in-place upgrade path from v3 to v4.

## Breaking Changes

- The BigQuery log destination was removed from the centralized logging created in step 1-org and replaced with the Log bucket destination with support for Log Analytics enabled and associated a BigQuery dataset.
- Customer-managed encryption keys (CMEK) were enabled for the Terraform state buckets create in 0-bootstrap.
- The configuration of Budget Alerts for the projects was changed from alarm by **spent** value to alarm by **forecast** value
- `compute.disableGuestAttributesAccess` organization policy was removed
-  Cloud Platform Resource Hierarchy changes:
  - Subfolders for business units were created in 4-projects step
  - A new Network folder was created be used as parent by network projects:
    - `prj-ENV-shared-base`
    - `prj-ENV-shared-restricted`
    - `prj-net-hub-base`
    - `prj-net-hub-restricted`
    - `prj-net-dns`
    - `prj-net-interconnect`
- Network Refactoring
  - Network projects are now created under a new folder `network`
  - VPC firewall rules (`google_compute_firewall`) resources were replaced with Compute Network firewall policy (`google_compute_network_firewall_policy`) resources

## Integrating New Features

There is no direct path for upgrading from v3 to v4 as this may result in resources getting deleted or recreated.

In case you require to integrate some of the v4's features, we recommend to review the documentation regarding the feature you are interested in and use v4's code as a guidance for its implementation. We also recommend to review the output from `terraform plan` for any destructive operations before applying the updates.

**Note:** You must verify that you are using the correct version for `terraform` and `gcloud`.
You can check these and other additional requirements using this [validate script](https://github.com/terraform-google-modules/terraform-example-foundation/blob/master/scripts/validate-requirements.sh).
