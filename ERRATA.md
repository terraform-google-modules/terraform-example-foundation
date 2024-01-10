# Errata Summary
This is an overview of the delta between the example foundation repository and the [Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf), including code discrepancies and notes on future automation. This document will be updated as new code is merged.

## 4.x [WIP]

### Code Discrepancies

#### Notes
- The "Alerting on log-based metrics and performance metrics" described in Section "Architecture/Detective controls" will be integrated in a future release.

## 3.x [WIP]

### Code Discrepancies

#### Networking

- The “allow-windows-activation” rule that exists in the code is not explicitly called out in the guide.
- [Tags](https://cloud.google.com/resource-manager/docs/tags/tags-overview) at Project level will be integrated in a future release.
- [Global network firewall policies](https://cloud.google.com/vpc/docs/network-firewall-policies) will be integrated in a future release.

#### Naming

- Firewall rules created for healthcheck in the transitivity infrastructure for the hub and spoke network model, do not follow the naming convention as recommended in the guide.

## 2.x [WIP]
### Code Discrepancies

#### Labeling
- The guide defines vpc-type for shared, service, float, nic, and peer projects. It does not define a vpc-type for Jenkins agents (vpc-b-jenkinsagents), the DNS Hub (vpc-dns-hub) and projects created in 4-projects.
This will be addressed in the next version of the blueprint guide.

#### Naming
- The Service Account naming is not aligned to the blueprint guide. Naming will be modified accordingly in a future release.
- The infrastructure pipeline project naming (`prj-buN-c-infra-pipeline`) is not aligned to the blueprint guide(`prj-buN-c-sample-infra-pipeline`). Naming will be modified accordingly in a future release.

#### Networking
- The “allow-windows-activation” rule that exists in the code is not explicitly called out in the guide.

#### Notes
- The BigQuery Log Detection solution, described in Section 10 will be integrated in a future release.
- Splunk log integration will be integrated in a future release.
- Cloud Asset Inventory will be integrated in a future release.
- The unallocated IP address space in the Shared VPC networks, described in Section 7.3, is currently being used by Private Service Networking in this release.

## [1.x](https://github.com/terraform-google-modules/terraform-example-foundation/releases/tag/v1.0.0)
### Code Discrepancies

#### Labeling
- The guide defines vpc-type for shared, service, float, nic, and peer projects. It does not define a vpc-type for Jenkins agents (vpc-b-jenkinsagents), the DNS Hub (vpc-dns-hub) and projects created in 4-projects.
This will be addressed in the next version of the blueprint guide.

#### Naming
- The Service Account & Storage bucket naming are not aligned to the blueprint guide. Naming will be modified accordingly in a future release.

#### Pre-deployment Check
- Terraform Validator, described in Section 5.2, is not implemented in the Cloud Build and Jenkins pipelines, but will be integrated in a future release.

#### Notes
- The BigQuery Log Detection solution, described in Section 10 will be integrated in a future release.
- Splunk log integration will be integrated in a future release.
- Cloud Asset Inventory will be integrated in a future release.
- The unallocated IP address space in the Shared VPC networks, described in Section 7.3, is currently being used by Private Service Networking in this release.
