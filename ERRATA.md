## Errata Summary
This is an overview of the delta between the example foundation repository and the [Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf), including code discrepancies and notes on future automation. This document will be updated as new code is merged.

### Code Discrepancies

##### Labeling
- The guide defines vpc-type for shared, service, float, nic, and peer projects. It does not define a vpc-type for Jenkins agents (vpc-b-jenkinsagents), the DNS Hub (vpc-dns-hub) and projects created in 4-projects.
This will be addressed in the next version of the whitepaper.

##### Naming
- The Service Account & Storage bucket naming are not aligned to the blueprint guide. Naming will be modified accordingly in a future release.

##### Pre-deployment Check
- Terraform Validator, described in Section 5.2, is not implemented in the Cloud Build and Jenkins pipelines, but will be integrated in a future release.

### Notes
- The BigQuery Log Detection solution, described in Section 10 will be integrated in a future release.
- Splunk log integration will be integrated in a future release.
- Cloud Asset Inventory will be integrated in a future release.
- The unallocated IP address space in the Shared VPC networks, described in Section 7.3, is currently being used by Private Service Networking in this release.
