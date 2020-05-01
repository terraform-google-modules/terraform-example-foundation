# terraform-example-foundation
This is an example repo showing how the CFT Terraform modules can be composed to build a secure GCP foundation.
The supplied structure and code is intended to form a starting point for building your own foundation with pragmatic defaults you can customize to meet your own requirements. Currently, the code leverages Google Cloud Build for deployment of the Terraform from step 2 onwards.
Cloud Build has been chosen to allow teams to quickly get started without needing to deploy a CI/CD tool, although it is worth noting the code can easily be executed by your preferred tool.

## Overview
This repo contains several distinct Terraform projects each within their own directory that must be applied seperately, but in sequence.
Each of these Terraform projects are to be layered on top of each other, running in the following order.

### 1. [bootstrap](./0-bootstrap/README.md)

This stage executes the [CFT Bootstrap module](https://github.com/terraform-google-modules/terraform-google-bootstrap) which bootstraps an existing GCP organization, creating all the required GCP resources & permissions to start using the Cloud Foundation Toolkit (CFT).
This includes; projects, service accounts and a Terraform state bucket. After executing this step, you will have the following structure:

```
example-organization/
├── cft-cloudbuild
└── cft-seed
```

In addition, this step uses the optional Cloud Build submodule, which sets up Cloud Build and Cloud Source Repositories for each of the stages below.
A simple trigger mechanism is configured, which runs a `terraform plan` for any non master branch and `terraform apply` when changes are merged to the master branch.
Usage instructions are available in the bootstrap [README](./0-bootstrap/README.md).

### 2. [org](./1-org/README.md)

The purpose of this stage is to set up top level folders used to house projects which contain shared resources such as monitoring, networking, org level logging and also to set baseline security settings through organizational policy.
This will create the following folder & project structure:

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

Under the logs folder, two projects are created. One for organization wide audit logs and another for billing logs.
In both cases the logs are collected into BigQuery datasets which can then be used general querying, dashboarding & reporting.
For the various audit log types being captured in BigQuery, this is mirroring the standard [retention periods](https://cloud.google.com/logging/quotas#logs_retention_periods) for Cloud Logging, these settings can be adjusted according to your requirements.

For billing data, a BigQuery dataset is created with permissions attached however you will need to configure a billing export [manually](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) as there is no easy way to automate this currently.

#### Monitoring

Under the monitoring folder, a project is created per environment (prod & nonprod) which is intended to be used as a [Cloud Monitoring workspace](https://cloud.google.com/monitoring/workspaces) for all projects in that environment.
Please note that creating the [workspace and linking projects](https://cloud.google.com/monitoring/workspaces/create) can currently only be completed through the Cloud Console.
If you have strong IAM requirements for these monitoring workspaces, it is worth considering creating these at a more granular level such as per business unit or per application.

#### Networking

Under the networking folder, a project is created per environment (prod & nonprod) which is intended to be used as a [Shared VPC Host project](https://cloud.google.com/vpc/docs/shared-vpc) for all projects in that environment.
This stage only creates the projects and enables the correct APIs, the following networks stage creates the actual Shared VPC networks.

#### Organization policy

Finally, the this step also applies a number of baseline [Organizational Policies](https://cloud.google.com/resource-manager/docs/organization-policy/overview).
It is important to understand what restrictions these policies are applying within your GCP organization, so please take the time to review and update these restrictions to meet your own requirements.
A full list of policies is [available here](https://cloud.google.com/resource-manager/docs/organization-policy/org-policy-constraints).

Usage instructions are available for the org step in the [README](./1-org/README.md).

### 3. [networks](./2-networks/README.md)

This step focuses on creating a Shared VPC per environment (prod & nonprod) in a standard configuration with a reasonable security baseline. Currently this includes:

- Example subnets for prod & non-prod inclusive of secondary ranges for those that want to use GKE.
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

This step, is focused on creating service projects in a standard configuration that are attached to the Shared VPC created in the previous step.
Running this code as-is should generate a structure as shown below:

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
The code in this step includes two options for creating projects.
The first is the standard projects module which creates a project per environment and the second creates a standalone project for one environment.
If relevant for your use case, there are also two optional submodules which can be used to create a subnet per project and a dedicated private DNS zone per project.

Usage instructions are available for the network step in the [README](./3-projects/README.md).

### Final view

Once all steps above have been executed your GCP organization should represent the structure shown below, with projects being the lowest nodes in the tree.

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
