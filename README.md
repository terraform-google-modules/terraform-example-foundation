# terraform-example-foundation
This is an example repo showing how the CFT terraform modules can be composed to build a secure GCP foundation. The supplied structure and code is intended to form a starting point for building your own foundation with pragmatic defaults you can customize to meet your own requirements. Currently, the code is built heavily around Cloud Build to allow teams to quickly get started without needing to deploy a CI/CD tool, although it is worth noting the code can easily be executed by your preferred tool.

## Overview
The repo contains several distinct terraform projects which are layered on top of each other, running in the following order.

### 1. [bootstrap](./0-bootstrap/README.md)

This stage is executes the [CFT Bootstrap module](https://github.com/terraform-google-modules/terraform-google-bootstrap) which bootstraps an existing GCP organization, creating all the required GCP resources & permissions to start using the Cloud Foundation Toolkit (CFT) including projects, service accounts and a terraform state bucket. After executing this step, you will have the following structure:

```
example-organization/
├── cft-cloudbuild
└── cft-seed
```

In addition, this step uses the optional Cloud Build submodule, which sets up Cloud Build and Cloud Source Repos for each of the stages below. A simple trigger methodology is configured, which runs a `terraform plan` for any non master branch and `terraform apply` when changes are merged to master. Usage instructions are available in the bootstrap [README](./0-bootstrap/README.md).

### 2. [org](./1-org/README.md)

The purpose of this stage is to setup top level shared folders, monitoring & networking projects, org level logging and set baseline security settings through organizational policy. This will create the following folder & project structure:

```
example-organization
└── common
    ├── logs
    │   ├── org-audit-logs
    │   └── org-billing-logs
    ├── monitoring
    │   ├── org-monitoring-nonprod
    │   └── org-monitoring-prod
    └── networking
        ├── org-shared-vpc-nonprod
        └── org-shared-vpc-prod
```
#### Logs

Underneath the logs folder, two projects are created for organization wide log for billing and audit logs, with BigQuery datasets created for dashboarding & reporting. For the various audit log types being captured in BigQuery, this is mirroring the standard [retention periods](https://cloud.google.com/logging/quotas#logs_retention_periods) for Cloud Logging, so please adjust them according to your requirements.

For the billing data, a BigQuery data set is created with permissions attached although you will need to configure a billing export [manually](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) as there is no easy way to automate this currently.

#### Monitoring

Underneath the monitoring folder, a project is created per environment (prod & nonprod) which is intended to be used as a [Cloud Monitoring workspace](https://cloud.google.com/monitoring/workspaces) for all projects in that environment. Please note that creating the [workspace and linking projects](https://cloud.google.com/monitoring/workspaces/create) is currently executed through the Cloud console. If you have strong IAM requirements for these monitoring workspaces, it is worth considering creating these at a more granular level like business unit or team.

#### Networking

Under the networking folder, a project is created per environment (prod & nonprod) which is intended to be used as a [Shared VPC Host project](https://cloud.google.com/vpc/docs/shared-vpc) for all projects in that environment. This stage only creates the projects and enables the correct APIs, the following networks stage creates the actual Shared VPC networks.

#### Organization policy

Finally, the org step also applies a number of baseline [Organizational Policies](https://cloud.google.com/resource-manager/docs/organization-policy/overview). It is important to understand what restrictions these policies are applying in your GCP Organization, so please take the time to review and update these restrictions to meet your own requirements if nessecary. A full list of policies is [available here](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints).

Usage instructions are available for the org step in the [README](./1-org/README.md).

### 3. [networks](./2-networks/README.md)

This step is focused on creating a Shared VPC per environment (prod/nonprod), in a standard configuration with a reasonable security baseline. Currently this includes:

- Example subnets for prod/non-prod with secondary ranges for those that want to use GKE.
- Default firewall rules created to allow remote access to VMs through IAP, without needing public IPs.
    - `allow-iap-ssh` and `allow-iap-rdp` network tags respectively
- Default firewall rule created to allow for load balancing using `allow-lb` tag.
- [Private service networking](https://cloud.google.com/vpc/docs/configure-private-services-access) configured to enable private Cloud SQL and Memorystore.
- [private.googleapis.com](https://cloud.google.com/vpc/docs/configure-private-google-access#private-domains) configured for private access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- Default routes to internet removed, with tag based route `egress-internet` required on VMs in order to reach the internet.
- Cloud NAT configured for all subnets with logging and static outbound IPs.
- Default Cloud DNS policy applied, with DNS logging and [inbound query forwarding](https://cloud.google.com/dns/docs/overview#dns-server-policy-in) turned on.

Usage instructions are available for the network step in the [README](./2-networks/README.md).

### 4. [projects](./3-projects/README.md)

This projects step, is focused on creating service projects in a standard configuration that are attached to the Shared VPC created earlier. Running this code as-is should generate a structure like this:

```
example-organization/
└── example-business-unit
    └── example-team
        ├── nonprod
        │   └── sample-standard-nonprod
        └── prod
            ├── sample-single-prod
            └── sample-standard-prod
```
The projects code includes two options for creating projects, one is the standard projects module which creates a project per environment and another which creates a standalone project for one environment. If relevant for your use case, there are also two optional submodules which can be used to create a subnet per project and a dedicated private DNS zone per project.

Usage instructions are available for the network step in the [README](./3-projects/README.md).

### Final view

Once all stages have been executed, your organization should look something like this with projects being the lowest nodes in the tree.

```
example-organization/
├── cft-cloudbuild
├── cft-seed
├── common
│   ├── logs
│   │   ├── org-audit-logs
│   │   └── org-billing-logs
│   ├── monitoring
│   │   ├── org-monitoring-nonprod
│   │   └── org-monitoring-prod
│   └── networking
│       ├── org-shared-vpc-nonprod
│       └── org-shared-vpc-prod
└── example-business-unit
    └── example-team
        ├── nonprod
        │   └── sample-standard-nonprod
        └── prod
            ├── sample-single-prod
            └── sample-standard-prod
```

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.
