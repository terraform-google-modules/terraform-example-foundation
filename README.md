# terraform-example-foundation

This example repository shows how the CFT Terraform modules can build a secure Google Cloud foundation, following the [Google Cloud Enterprise Foundations Blueprint](https://cloud.google.com/architecture/security-foundations) (previously called the _Security Foundations Guide_).
The supplied structure and code is intended to form a starting point for building your own foundation with pragmatic defaults that you can customize to meet your own requirements.

The intended audience of this blueprint is large enterprise organizations with a dedicated platform team responsible for deploying and maintaining their GCP environment, who is commited to separation of duties across multiple teams and managing their environment solely through version-controlled Infrastructure as Code. Smaller organizations looking for a turnkey solution might prefer other options such as [Google Cloud Setup](https://console.cloud.google.com/cloud-setup/overview)

## Intended usage and support

This repository is intended as an example to be forked, tweaked, and maintained in the user's own version-control system; the modules within this repository are not intended for use as remote references.
Though this blueprint can help accelerate your foundation design and build, we assume that you have the engineering skills and teams to deploy and customize your own foundation based on your own requirements.

We will support:
 - Code is semantically valid, pinned to known good versions, and passes terraform validate and lint checks
 - All PR to this repo must pass integration tests to deploy all resources into a test environment before being merged
 - Feature requests about ease of use of the code, or feature requests that generally apply to all users, are welcome

We will not support:
 - In-place upgrades from a foundation deployed with an earlier version to a more recent version, even for minor version changes, might not be feasible. Repository maintainers do not have visibility to what resources a user deploys on top of their foundation or how the foundation was customized in deployment, so we make no guarantee about avoiding breaking changes.
 - Feature requests that are specific to a single user's requirement and not representative of general best practices

## Overview

This repo contains several distinct Terraform projects, each within their own directory that must be applied separately, but in sequence.
Stage `0-bootstrap` is manually executed, and subsequent stages are executed using your preferred CI/CD tool.

Each of these Terraform projects are to be layered on top of each other, and run in the following order.

### [0. bootstrap](./0-bootstrap/)

This stage executes the [CFT Bootstrap module](https://github.com/terraform-google-modules/terraform-google-bootstrap) which bootstraps an existing Google Cloud organization, creating all the required Google Cloud resources and permissions to start using the Cloud Foundation Toolkit (CFT).
For [CI/CD Pipelines](/docs/GLOSSARY.md#foundation-cicd-pipeline), you can use either Cloud Build (by default) or Jenkins. If you want to use Jenkins instead of Cloud Build, see [README-Jenkins](./0-bootstrap/README-Jenkins.md) on how to use the Jenkins sub-module.

The bootstrap step includes:

- The `prj-b-seed` project that contains the following:
  - Terraform state bucket
  - Custom service accounts used by Terraform to create new resources in Google Cloud
- The `prj-b-cicd` project that contains the following:
  - A [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) implemented with either Cloud Build or Jenkins
  - If using Cloud Build, the following items:
    - Cloud Source Repository
    - Artifact Registry
  - If using Jenkins, the following items:
    - A Compute Engine instance configured as a Jenkins Agent
    - Custom service account to run Compute Engine instances for Jenkins Agents
    - VPN connection with on-prem (or wherever your Jenkins Controller is located)

It is a best practice to separate concerns by having two projects here: one for the Terraform state and one for the CI/CD tool.
  - The `prj-b-seed` project stores Terraform state and has the service accounts that can create or modify infrastructure.
  - The `prj-b-cicd` project holds the CI/CD tool (either Cloud Build or Jenkins) that coordinates the infrastructure deployment.

To further separate the concerns at the IAM level as well, a distinct service account is created for each stage. The Terraform custom service accounts are granted the IAM permissions required to build the foundation.
If using Cloud Build as the CI/CD tool, these service accounts are used directly in the pipeline to execute the pipeline steps (`plan` or `apply`).
In this configuration, the baseline permissions of the CI/CD tool are unchanged.

If using Jenkins as the CI/CD tool, the service account of the Jenkins Agent (`sa-jenkins-agent-gce@prj-b-cicd-xxxx.iam.gserviceaccount.com`) is granted [impersonation](https://cloud.google.com/iam/docs/create-short-lived-credentials-direct) access so it can generate tokens over the Terraform custom Service Accounts.
In this configuration, the baseline permissions of the CI/CD tool are limited.

After executing this step, you will have the following structure:

```
example-organization/
└── fldr-bootstrap
    ├── prj-b-cicd
    └── prj-b-seed
```

When this step uses the Cloud Build submodule, it sets up the cicd project (`prj-b-cicd`) with Cloud Build and Cloud Source Repositories for each of the stages below.
Triggers are configured to run a `terraform plan` for any non-environment branch and `terraform apply` when changes are merged to an environment branch (`development`, `nonproduction` or `production`).
Usage instructions are available in the 0-bootstrap [README](./0-bootstrap/README.md).

### [1. org](./1-org/)

The purpose of this stage is to set up the common folder used to house projects that contain shared resources such as Security Command Center notification, Cloud Key Management Service (KMS), org level secrets, and org level logging.
This stage also sets up the network folder used to house network related projects such as DNS Hub, Interconnect, network hub, and base and restricted projects for each environment  (`development`, `nonproduction` or `production`).
This will create the following folder and project structure:

```
example-organization
└── fldr-common
    ├── prj-c-logging
    ├── prj-c-billing-export
    ├── prj-c-scc
    ├── prj-c-kms
    └── prj-c-secrets
└── fldr-network
    ├── prj-net-hub-base
    ├── prj-net-hub-restricted
    ├── prj-net-dns
    ├── prj-net-interconnect
    ├── prj-d-shared-base
    ├── prj-d-shared-restricted
    ├── prj-n-shared-base
    ├── prj-n-shared-restricted
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
```

#### Logs

Under the common folder, a project `prj-c-logging` is used as the destination for organization wide sinks. This includes admin activity audit logs from all projects in your organization and the billing account.

Logs are collected into a logging bucket with a linked BigQuery dataset, which can be used for ad-hoc log investigations, querying, or reporting. Log sinks can also be configured to export to Pub/Sub for exporting to external systems or Cloud Storage for long-term storage.

**Notes**:

- Log export to Cloud Storage bucket has optional object versioning support via `log_export_storage_versioning`.
- The various audit log types being captured in BigQuery are retained for 30 days.
- For billing data, a BigQuery dataset is created with permissions attached, however you will need to configure a billing export [manually](https://cloud.google.com/billing/docs/how-to/export-data-bigquery), as there is no easy way to automate this at the moment.

#### Security Command Center notification

Another project created under the common folder. This project will host the Security Command Center notification resources at the organization level.
This project will contain a Pub/Sub topic, a Pub/Sub subscription, and a [Security Command Center notification](https://cloud.google.com/security-command-center/docs/how-to-notifications) configured to send all new findings to the created topic.
You can adjust the filter when deploying this step.

#### KMS

Another project created under the common folder. This project is allocated for [Cloud Key Management](https://cloud.google.com/security-key-management) for KMS resources shared by the organization.

Usage instructions are available for the org step in the [README](./1-org/README.md).

#### Secrets

Another project created under the common folder. This project is allocated for [Secret Manager](https://cloud.google.com/secret-manager) for secrets shared by the organization.

Usage instructions are available for the org step in the [README](./1-org/README.md).

#### DNS hub

This project is created under the network folder. This project will host the DNS hub for the organization.

#### Interconnect

Another project created under the network folder. This project will host the Dedicated Interconnect [Interconnect connection](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/terminology#elements) for the organization. In case of Partner Interconnect, this project is unused and the [VLAN attachments](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/terminology#for-partner-interconnect) will be placed directly into the corresponding hub projects.

#### Networking

Under the network folder, two projects, one for base and another for restricted network, are created per environment (`development`, `nonproduction`, and `production`) which is intended to be used as a [Shared VPC host project](https://cloud.google.com/vpc/docs/shared-vpc) for all projects in that environment.
This stage only creates the projects and enables the correct APIs, the following networks stages, [3-networks-dual-svpc](./3-networks-dual-svpc/) and [3-networks-hub-and-spoke](./3-networks-hub-and-spoke/), create the actual Shared VPC networks.

### [2. environments](./2-environments/)

The purpose of this stage is to set up the environments folders that contain shared projects for each environemnt.
This will create the following folder and project structure:

```
example-organization
└── fldr-development
    ├── prj-d-kms
    └── prj-d-secrets
└── fldr-nonproduction
    ├── prj-n-kms
    └── prj-n-secrets
└── fldr-production
    ├── prj-p-kms
    └── prj-p-secrets
```

#### KMS

Under the environment folder, a project is created per environment (`development`, `nonproduction`, and `production`), which is intended to be used by [Cloud Key Management](https://cloud.google.com/security-key-management) for KMS resources shared by the environment.

Usage instructions are available for the environments step in the [README](./2-environments/README.md).

#### Secrets

Under the environment folder, a project is created per environment (`development`, `nonproduction`, and `production`), which is intended to be used by [Secret Manager](https://cloud.google.com/secret-manager) for secrets shared by the environment.

Usage instructions are available for the environments step in the [README](./2-environments/README.md).

### [3. networks-dual-svpc](./3-networks-dual-svpc/)

This step focuses on creating a [Shared VPC](https://cloud.google.com/architecture/security-foundations/networking#vpcsharedvpc-id7-1-shared-vpc-) per environment (`development`, `nonproduction`, and `production`) in a standard configuration with a reasonable security baseline. Currently, this includes:

- (Optional) Example subnets for `development`, `nonproduction`, and `production` inclusive of secondary ranges for those that want to use Google Kubernetes Engine.
- Hierarchical firewall policy created to allow remote access to [VMs through IAP](https://cloud.google.com/iap/docs/using-tcp-forwarding), without needing public IPs.
- Hierarchical firewall policy created to allow for [load balancing health checks](https://cloud.google.com/load-balancing/docs/health-checks#firewall_rules).
- Hierarchical firewall policy created to allow [Windows KMS activation](https://cloud.google.com/compute/docs/instances/windows/creating-managing-windows-instances#kms-server).
- [Private service networking](https://cloud.google.com/vpc/docs/configure-private-services-access) configured to enable workload dependant resources like Cloud SQL.
- Base Shared VPC with [private.googleapis.com](https://cloud.google.com/vpc/docs/configure-private-google-access#private-domains) configured for base access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- Restricted Shared VPC with [restricted.googleapis.com](https://cloud.google.com/vpc-service-controls/docs/supported-products) configured for restricted access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- Default routes to internet removed, with tag based route `egress-internet` required on VMs in order to reach the internet.
- (Optional) Cloud NAT configured for all subnets with logging and static outbound IPs.
- Default Cloud DNS policy applied, with DNS logging and [inbound query forwarding](https://cloud.google.com/dns/docs/overview#dns-server-policy-in) turned on.

Usage instructions are available for the networks step in the [README](./3-networks-dual-svpc/README.md).

### [3. networks-hub-and-spoke](./3-networks-hub-and-spoke/)

This step configures the same network resources that the step 3-networks-dual-svpc does, but this time it makes use of the architecture based on the [hub-and-spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) reference network model.

Usage instructions are available for the networks step in the [README](./3-networks-hub-and-spoke/README.md).

### [4. projects](./4-projects/)

This step is focused on creating service projects with a standard configuration that are attached to the Shared VPC created in the previous step and application infrastructure pipelines.
Running this code as-is should generate a structure as shown below:

```
example-organization/
└── fldr-development
    └── fldr-development-bu1
        ├── prj-d-bu1-sample-floating
        ├── prj-d-bu1-sample-base
        ├── prj-d-bu1-sample-restrict
        ├── prj-d-bu1-sample-peering
    └── fldr-development-bu2
        ├── prj-d-bu2-sample-floating
        ├── prj-d-bu2-sample-base
        ├── prj-d-bu2-sample-restrict
        └── prj-d-bu2-sample-peering
└── fldr-nonproduction
    └── fldr-nonproduction-bu1
        ├── prj-n-bu1-sample-floating
        ├── prj-n-bu1-sample-base
        ├── prj-n-bu1-sample-restrict
        ├── prj-n-bu1-sample-peering
    └── fldr-nonproduction-bu2
        ├── prj-n-bu2-sample-floating
        ├── prj-n-bu2-sample-base
        ├── prj-n-bu2-sample-restrict
        └── prj-n-bu2-sample-peering
└── fldr-production
    └── fldr-production-bu1
        ├── prj-p-bu1-sample-floating
        ├── prj-p-bu1-sample-base
        ├── prj-p-bu1-sample-restrict
        ├── prj-p-bu1-sample-peering
    └── fldr-production-bu2
        ├── prj-p-bu2-sample-floating
        ├── prj-p-bu2-sample-base
        ├── prj-p-bu2-sample-restrict
        └── prj-p-bu2-sample-peering
└── fldr-common
    ├── prj-c-bu1-infra-pipeline
    └── prj-c-bu2-infra-pipeline
```

The code in this step includes two options for creating projects.
The first is the standard projects module which creates a project per environment, and the second creates a standalone project for one environment.
If relevant for your use case, there are also two optional submodules which can be used to create a subnet per project, and a dedicated private DNS zone per project.

Usage instructions are available for the projects step in the [README](./4-projects/README.md).

### [5. app-infra](./5-app-infra/)

The purpose of this step is to deploy a simple [Compute Engine](https://cloud.google.com/compute/) instance in one of the business unit projects using the infra pipeline set up in 4-projects.

Usage instructions are available for the app-infra step in the [README](./5-app-infra/README.md).

### Final view

After all steps above have been executed, your Google Cloud organization should represent the structure shown below, with projects being the lowest nodes in the tree.

```
example-organization
└── fldr-common
    ├── prj-c-logging
    ├── prj-c-billing-export
    ├── prj-c-scc
    ├── prj-c-kms
    ├── prj-c-secrets
    ├── prj-c-bu1-infra-pipeline
    └── prj-c-bu2-infra-pipeline
└── fldr-network
    ├── prj-net-hub-base
    ├── prj-net-hub-restricted
    ├── prj-net-dns
    ├── prj-net-interconnect
    ├── prj-d-shared-base
    ├── prj-d-shared-restricted
    ├── prj-n-shared-base
    ├── prj-n-shared-restricted
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
└── fldr-development
    ├── prj-d-kms
    └── prj-d-secrets
    └── fldr-development-bu1

        ├── prj-d-bu1-sample-floating
        ├── prj-d-bu1-sample-base
        ├── prj-d-bu1-sample-restrict
        ├── prj-d-bu1-sample-peering
    └── fldr-development-bu2

        ├── prj-d-bu2-sample-floating
        ├── prj-d-bu2-sample-base
        ├── prj-d-bu2-sample-restrict
        └── prj-d-bu2-sample-peering
└── fldr-nonproduction
    ├── prj-n-kms
    └── prj-n-secrets
    └── fldr-nonproduction-bu1

        ├── prj-n-bu1-sample-floating
        ├── prj-n-bu1-sample-base
        ├── prj-n-bu1-sample-restrict
        ├── prj-n-bu1-sample-peering
    └── fldr-nonproduction-bu2

        ├── prj-n-bu2-sample-floating
        ├── prj-n-bu2-sample-base
        ├── prj-n-bu2-sample-restrict
        └── prj-n-bu2-sample-peering
└── fldr-production
    ├── prj-p-kms
    └── prj-p-secrets
    └── fldr-production-bu1

        ├── prj-p-bu1-sample-floating
        ├── prj-p-bu1-sample-base
        ├── prj-p-bu1-sample-restrict
        ├── prj-p-bu1-sample-peering
    └── fldr-production-bu2

        ├── prj-p-bu2-sample-floating
        ├── prj-p-bu2-sample-base
        ├── prj-p-bu2-sample-restrict
        └── prj-p-bu2-sample-peering
└── fldr-bootstrap
    ├── prj-b-cicd
    └── prj-b-seed
```

### Branching strategy

There are three main named branches: `development`, `nonproduction`, and `production` that reflect the corresponding environments. These branches should be [protected](https://docs.github.com/en/github/administering-a-repository/about-protected-branches). When the [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) (Jenkins or Cloud Build) runs on a particular named branch (say for instance `development`), only the corresponding environment (`development`) is applied. An exception is the `shared` environment, which is only applied when triggered on the `production` branch. This is because any changes in the `shared` environment may affect resources in other environments and can have adverse effects if not validated correctly.

Development happens on feature and bug fix branches (which can be named `feature/new-foo`, `bugfix/fix-bar`, etc.) and when complete, a [pull request (PR)](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests) or [merge request (MR)](https://docs.gitlab.com/ee/user/project/merge_requests/) can be opened targeting the `development` branch. This will trigger the [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) to perform a plan and validate against all environments (`development`, `nonproduction`, `shared`, and `production`). After the code review is complete and changes are validated, this branch can be merged into `development`. This will trigger a [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline) that applies the latest changes in the `development` branch on the `development` environment.

After validated in `development`, changes can be promoted to `nonproduction` by opening a PR or MR targeting the `nonproduction` branch and merging them. Similarly, changes can be promoted from `nonproduction` to `production`.

### Policy validation

This repo uses the [terraform-tools](https://cloud.google.com/docs/terraform/policy-validation/validate-policies) component of the `gcloud` CLI to validate the Terraform plans against a [library of Google Cloud policies](https://github.com/GoogleCloudPlatform/policy-library).

The [Scorecard bundle](https://github.com/GoogleCloudPlatform/policy-library/blob/master/docs/bundles/scorecard-v1.md) was used to create the [policy-library folder](./policy-library) with [one extra constraint](https://github.com/GoogleCloudPlatform/policy-library/blob/master/samples/serviceusage_allow_basic_apis.yaml) added.

See the [policy-library documentation](https://github.com/GoogleCloudPlatform/policy-library/blob/master/docs/index.md) if you need to add more constraints from the [samples folder](https://github.com/GoogleCloudPlatform/policy-library/tree/master/samples) in your configuration based in your type of workload.

Step 1-org has [instructions](./1-org/README.md#deploying-with-cloud-build) on the creation of the shared repository to host these policies.

### Optional Variables

Some variables used to deploy the steps have default values, check those **before deployment** to ensure they match your requirements. For more information, there are tables of inputs and outputs for the Terraform modules, each with a detailed description of their variables. Look for variables marked as **not required** in the section **Inputs** of these READMEs:

- Step 0-bootstrap: If you are using Cloud Build in the [CI/CD Pipeline](/docs/GLOSSARY.md#foundation-cicd-pipeline), check the main [README](./0-bootstrap/README.md#Inputs) of the step. If you are using Jenkins, check the [README](./0-bootstrap/modules/jenkins-agent/README.md#Inputs) of the module `jenkins-agent`.
- Step 1-org: The [README](./1-org/envs/shared/README.md#Inputs) of the environment `shared`.
- Step 2-environments: The READMEs of the environments [development](./2-environments/envs/development/README.md#Inputs), [nonproduction](./2-environments/envs/nonproduction/README.md#Inputs), and [production](./2-environments/envs/production/README.md#Inputs)
- Step 3-networks-dual-svpc: The READMEs of the environments [shared](./3-networks-dual-svpc/envs/shared/README.md#inputs), [development](./3-networks-dual-svpc/envs/development/README.md#Inputs), [nonproduction](./3-networks/envs/nonproduction/README.md#Inputs), and [production](./3-networks/envs/production/README.md#Inputs)
- Step 3-networks-hub-and-spoke: The READMEs of the environments [shared](./3-networks-hub-and-spoke/envs/shared/README.md#inputs), [development](./3-networks-hub-and-spoke/envs/development/README.md#Inputs), [nonproduction](./3-networks/envs/nonproduction/README.md#Inputs), and [production](./3-networks/envs/production/README.md#Inputs)
- Step 4-projects: The READMEs of the environments [shared](./4-projects/business_unit_1/shared/README.md#inputs), [development](./4-projects/business_unit_1/development/README.md#Inputs), [nonproduction](./4-projects/business_unit_1/nonproduction/README.md#Inputs), and [production](./4-projects/business_unit_1/production/README.md#Inputs)

## Errata summary

Refer to the [errata summary](./ERRATA.md) for an overview of the delta between the example foundation repository and the [Google Cloud security foundations guide](https://cloud.google.com/architecture/security-foundations).

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for information on contributing to this module.
