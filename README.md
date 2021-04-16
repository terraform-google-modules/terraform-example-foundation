# terraform-example-foundation
This is an example repo showing how the CFT Terraform modules can be composed to build a secure GCP foundation, following the [Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf).
The supplied structure and code is intended to form a starting point for building your own foundation with pragmatic defaults you can customize to meet your own requirements. Currently, the step 0 is manually executed.
From step 1 onwards, the Terraform code is deployed by leveraging either Google Cloud Build (by default) or Jenkins.
Cloud Build has been chosen by default to allow teams to quickly get started without needing to deploy a CI/CD tool, although it is worth noting the code can easily be executed by your preferred tool.

## Overview
This repo contains several distinct Terraform projects each within their own directory that must be applied separately, but in sequence.
Each of these Terraform projects are to be layered on top of each other, running in the following order.

### [0. bootstrap](./0-bootstrap/)

This stage executes the [CFT Bootstrap module](https://github.com/terraform-google-modules/terraform-google-bootstrap) which bootstraps an existing GCP organization, creating all the required GCP resources & permissions to start using the Cloud Foundation Toolkit (CFT).
For CI/CD pipelines, you can use either Cloud Build (by default) or Jenkins. If you want to use Jenkins instead of Cloud Build, please see [README-Jenkins](./0-bootstrap/README-Jenkins.md) on how to use the included Jenkins sub-module.

The bootstrap step includes:
- The `prj-b-seed` project, which contains:
  - Terraform state bucket
  - Custom Service Account used by Terraform to create new resources in GCP
- The `prj-b-cicd` project, which contains:
  - A CI/CD pipeline implemented with either Cloud Build or Jenkins
  - If using Cloud Build:
    - Cloud Source Repository
  - If using Jenkins:
    - A GCE Instance configured as a Jenkins Agent
    - Custom Service Account to run Jenkins Agents GCE instances
    - VPN connection with on-prem (or where ever your Jenkins Master is located)

It is a best practice to separate concerns by having two projects here: one for the CFT resources and one for the CI/CD tool.
The `prj-b-seed` project stores Terraform state and has the Service Account able to create / modify infrastructure.
On the other hand, the deployment of that infrastructure is coordinated by a CI/CD tool of your choice allocated in a second project named `prj-b-cicd`.

To further separate the concerns at the IAM level as well, the service account of the CI/CD tool is given different permissions than the Terraform account.
The CI/CD tool account (`@cloudbuild.gserviceaccount.com` if using Cloud Build and `sa-jenkins-agent-gce@prj-b-cicd-xxxx.iam.gserviceaccount.com` if using Jenkins) is granted access to generate tokens over the Terraform custom service account.
In this configuration, the baseline permissions of the CI/CD tool are limited, and the Terraform custom Service Account is granted the IAM permissions required to build the foundation.

After executing this step, you will have the following structure:

```
example-organization/
└── fldr-bootstrap
    ├── prj-b-cicd
    └── prj-b-seed
```

When this step uses the Cloud Build submodule, it sets up Cloud Build and Cloud Source Repositories for each of the stages below.
Triggers are configured to run a `terraform plan` for any non environment branch and `terraform apply` when changes are merged to an environment branch (`development`, `non-production` & `production`).
Usage instructions are available in the 0-bootstrap [README](./0-bootstrap/README.md).

### [1. org](./1-org/)

The purpose of this stage is to set up the common folder used to house projects which contain shared resources such as DNS Hub, Interconnect, SCC Notification, org level secrets, Network Hub and org level logging.
This will create the following folder & project structure:

```
example-organization
└── fldr-common
    ├── prj-c-logging
    ├── prj-c-base-net-hub
    ├── prj-c-billing-logs
    ├── prj-c-dns-hub
    ├── prj-c-interconnect
    ├── prj-c-restricted-net-hub
    ├── prj-c-scc
    └── prj-c-secrets
```

#### Logs

Among the eight projects created under the common folder, two projects (`prj-c-logging`, `prj-c-billing-logs`) are used for logging.
The first one for organization wide audit logs, and the latter for billing logs.
In both cases the logs are collected into BigQuery datasets which can then be used general querying, dashboarding & reporting. Logs are also exported to Pub/Sub and GCS bucket.

**Notes**:

- Log export to GCS bucket has optional object versioning support via `log_export_storage_versioning`.
- The various audit log types being captured in BigQuery are retained for 30 days.
- For billing data, a BigQuery dataset is created with permissions attached, however you will need to configure a billing export [manually](https://cloud.google.com/billing/docs/how-to/export-data-bigquery), as there is no easy way to automate this at the moment.

#### DNS Hub

Another project created under the common folder. This project will host the DNS Hub for the organization.

#### Interconnect

Another project created under the common folder. This project will host the Dedicated Interconnect [Interconnect connection](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/terminology#elements) for the organization. In case of the Partner Interconnect this project is unused and the [VLAN attachments](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/terminology#for-partner-interconnect) will be placed directly into the corresponding Hub projects.

#### SCC Notification

Another project created under the common folder. This project will host the SCC Notification resources at the organization level.
This project will contain a Pub/Sub topic and subscription, a [SCC Notification](https://cloud.google.com/security-command-center/docs/how-to-notifications) configured to send all new Findings to the topic created.
You can adjust the filter when deploying this step.

#### Secrets

Another project created under the common folder. This project is allocated for [GCP Secret Manager](https://cloud.google.com/secret-manager) for secrets shared by the organization.

Usage instructions are available for the org step in the [README](./1-org/README.md).

### [2. environments](./2-environments/)

The purpose of this stage is to set up the environments folders used to house projects which contain monitoring, secrets, networking projects.
This will create the following folder & project structure:

```
example-organization
└── fldr-development
    ├── prj-d-monitoring
    ├── prj-d-secrets
    ├── prj-d-shared-base
    └── prj-d-shared-restricted
└── fldr-non-production
    ├── prj-n-monitoring
    ├── prj-n-secrets
    ├── prj-n-shared-base
    └── prj-n-shared-restricted
└── fldr-production
    ├── prj-p-monitoring
    ├── prj-p-secrets
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
```

#### Monitoring

Under the environment folder, a project is created per environment (`development`, `non-production` & `production`), which is intended to be used as a [Cloud Monitoring workspace](https://cloud.google.com/monitoring/workspaces) for all projects in that environment.
Please note that creating the [workspace and linking projects](https://cloud.google.com/monitoring/workspaces/create) can currently only be completed through the Cloud Console.
If you have strong IAM requirements for these monitoring workspaces, it is worth considering creating these at a more granular level, such as per business unit or per application.

#### Networking

Under the environment folder, two projects, one for base and another for restricted network, are created per environment (`development`, `non-production` & `production`) which is intended to be used as a [Shared VPC Host project](https://cloud.google.com/vpc/docs/shared-vpc) for all projects in that environment.
This stage only creates the projects and enables the correct APIs, the following [networks stage](./3-networks/) creates the actual Shared VPC networks.

#### Secrets

Under the environment folder, a project is created per environment (`development`, `non-production` & `production`), which is intended to be used by [GCP Secret Manager](https://cloud.google.com/secret-manager) for secrets shared by the environment.

Usage instructions are available for the environments step in the [README](./2-environments/README.md).

### [3. networks](./3-networks/)

This step focuses on creating a Shared VPC per environment (`development`, `non-production` & `production`) in a standard configuration with a reasonable security baseline. Currently, this includes:

- Optional - Example subnets for `development`, `non-production` & `production` inclusive of secondary ranges for those that want to use GKE.
- Optional - Default firewall rules created to allow remote access to [VMs through IAP](https://cloud.google.com/iap/docs/using-tcp-forwarding), without needing public IPs.
  - `allow-iap-ssh` and `allow-iap-rdp` network tags respectively.
- Optional - Default firewall rule created to allow for [load balancing health checks](https://cloud.google.com/load-balancing/docs/health-checks#firewall_rules) using `allow-lb` tag.
- Optional - Default firewall rule created to allow [Windows KMS activation](https://cloud.google.com/compute/docs/instances/windows/creating-managing-windows-instances#kms-server) using `allow-win-activation` tag.
- [Private service networking](https://cloud.google.com/vpc/docs/configure-private-services-access) configured to enable workload dependant resources like Cloud SQL.
- Base Shared VPC with [private.googleapis.com](https://cloud.google.com/vpc/docs/configure-private-google-access#private-domains) configured for base access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- Restricted Shared VPC with [restricted.googleapis.com](https://cloud.google.com/vpc-service-controls/docs/supported-products) configured for restricted access to googleapis.com and gcr.io. Route added for VIP so no internet access is required to access APIs.
- Default routes to internet removed, with tag based route `egress-internet` required on VMs in order to reach the internet.
- Optional - Cloud NAT configured for all subnets with logging and static outbound IPs.
- Default Cloud DNS policy applied, with DNS logging and [inbound query forwarding](https://cloud.google.com/dns/docs/overview#dns-server-policy-in) turned on.

Usage instructions are available for the networks step in the [README](./3-networks/README.md).

### [4. projects](./4-projects/)

This step is focused on creating service projects with a standard configuration that are attached to the Shared VPC created in the previous step and application infrastructure pipelines.
Running this code as-is should generate a structure as shown below:

```
example-organization/
└── fldr-development
    ├── prj-bu1-d-env-secrets
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-base
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu1-d-sample-peering
    ├── prj-bu2-d-env-secrets
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-base
    ├── prj-bu2-d-sample-restrict
    └── prj-bu2-d-sample-peering
└── fldr-non-production
    ├── prj-bu1-n-env-secrets
    ├── prj-bu1-n-sample-floating
    ├── prj-bu1-n-sample-base
    ├── prj-bu1-n-sample-restrict
    ├── prj-bu1-n-sample-peering
    ├── prj-bu2-n-env-secrets
    ├── prj-bu2-n-sample-floating
    ├── prj-bu2-n-sample-base
    ├── prj-bu2-n-sample-restrict
    └── prj-bu2-n-sample-peering
└── fldr-production
    ├── prj-bu1-p-env-secrets
    ├── prj-bu1-p-sample-floating
    ├── prj-bu1-p-sample-base
    ├── prj-bu1-p-sample-restrict
    ├── prj-bu1-p-sample-peering
    ├── prj-bu2-p-env-secrets
    ├── prj-bu2-p-sample-floating
    ├── prj-bu2-p-sample-base
    ├── prj-bu2-p-sample-restrict
    └── prj-bu2-p-sample-peering
└── fldr-common
    ├── prj-bu1-c-infra-pipeline
    └── prj-bu2-c-infra-pipeline
```

The code in this step includes two options for creating projects.
The first is the standard projects module which creates a project per environment, and the second creates a standalone project for one environment.
If relevant for your use case, there are also two optional submodules which can be used to create a subnet per project, and a dedicated private DNS zone per project.

Usage instructions are available for the projects step in the [README](./4-projects/README.md).

### Final View

Once all steps above have been executed your GCP organization should represent the structure shown below, with projects being the lowest nodes in the tree.

```
example-organization
└── fldr-common
    ├── prj-c-logging
    ├── prj-c-base-net-hub
    ├── prj-c-billing-logs
    ├── prj-c-dns-hub
    ├── prj-c-interconnect
    ├── prj-c-restricted-net-hub
    ├── prj-c-scc
    ├── prj-c-secrets
    ├── prj-bu1-c-infra-pipeline
    └── prj-bu2-c-infra-pipeline
└── fldr-development
    ├── prj-bu1-d-env-secrets
    ├── prj-bu1-d-sample-floating
    ├── prj-bu1-d-sample-base
    ├── prj-bu1-d-sample-restrict
    ├── prj-bu1-d-sample-peering
    ├── prj-bu2-d-env-secrets
    ├── prj-bu2-d-sample-floating
    ├── prj-bu2-d-sample-base
    ├── prj-bu2-d-sample-restrict
    ├── prj-bu2-d-sample-peering
    ├── prj-d-monitoring
    ├── prj-d-secrets
    ├── prj-d-shared-base
    └── prj-d-shared-restricted
└── fldr-non-production
    ├── prj-bu1-n-env-secrets
    ├── prj-bu1-n-sample-floating
    ├── prj-bu1-n-sample-base
    ├── prj-bu1-n-sample-restrict
    ├── prj-bu1-n-sample-peering
    ├── prj-bu2-n-env-secrets
    ├── prj-bu2-n-sample-floating
    ├── prj-bu2-n-sample-base
    ├── prj-bu2-n-sample-restrict
    ├── prj-bu2-n-sample-peering
    ├── prj-n-monitoring
    ├── prj-n-secrets
    ├── prj-n-shared-base
    └── prj-n-shared-restricted
└── fldr-production
    ├── prj-bu1-p-env-secrets
    ├── prj-bu1-p-sample-floating
    ├── prj-bu1-p-sample-base
    ├── prj-bu1-p-sample-restrict
    ├── prj-bu1-p-sample-peering
    ├── prj-bu2-p-env-secrets
    ├── prj-bu2-p-sample-floating
    ├── prj-bu2-p-sample-base
    ├── prj-bu2-p-sample-restrict
    ├── prj-bu2-p-sample-peering
    ├── prj-p-monitoring
    ├── prj-p-secrets
    ├── prj-p-shared-base
    └── prj-p-shared-restricted
└── fldr-bootstrap
    ├── prj-b-cicd
    └── prj-b-seed
```

### Branching strategy

There are three main named branches - `development`, `non-production` and `production` that reflect the corresponding environments. These branches should be [protected](https://docs.github.com/en/github/administering-a-repository/about-protected-branches). When the CI/CD pipeline (Jenkins/CloudBuild) runs on a particular named branch (say for instance `development`), only the corresponding environment (`development`) is applied. An exception is the `shared` environment which is only applied when triggered on the `production` branch. This is because any changes in the `shared` environment may affect resources in other environments and can have adverse effects if not validated correctly.

Development happens on feature/bugfix branches (which can be named `feature/new-foo`, `bugfix/fix-bar`, etc.) and when complete, a [pull request (PR)](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests) or [merge request (MR)](https://docs.gitlab.com/ee/user/project/merge_requests/) can be opened targeting the `development` branch. This will trigger the CI pipeline to perform a plan and validate against all environments (`development`, `non-production`, `shared` and `production`). Once code review is complete and changes are validated, this branch can be merged into `development`. This will trigger a CI pipeline that applies the latest changes in the `development` branch on the `development` environment.

Once validated in `development`, changes can be promoted to `non-production` by opening a PR/MR targeting the `non-production` branch and merging them. Similarly, changes can be promoted from `non-production` to `production`.

### Terraform-validator

This repo uses [terraform-validator](https://github.com/GoogleCloudPlatform/terraform-validator) to validate the terraform plans against Forseti Security Config Validator [Policy Library](https://github.com/forseti-security/policy-library).

The [Scorecard bundle](https://github.com/forseti-security/policy-library/blob/master/docs/bundles/scorecard-v1.md) was used to create the [policy-library folder](./policy-library) with [one extra constraint](https://github.com/forseti-security/policy-library/blob/master/samples/serviceusage_allow_basic_apis.yaml) added.

See the [policy-library documentation](https://github.com/forseti-security/policy-library/blob/master/docs/index.md) if you need to add more constraints from the [samples folder](https://github.com/forseti-security/policy-library/tree/master/samples) in your configuration based in your type of workload.

Step 1-org has instructions on the creation of the shared repository to host these policies.

### Optional Variables

Some variables used to deploy the steps have default values, check those **before deployment** to ensure they match your requirements. For more information, there are tables of inputs and outputs for the Terraform modules, each with a detailed description of their variables. Look for variables marked as **not required** in the section **Inputs** of these READMEs:

- Step 0-bootstrap: If you are using Cloud Build in the CICD pipeline, check the main [README](./0-bootstrap/README.md#Inputs) of the step. If you are using Jenkins, check the [README](./0-bootstrap/modules/jenkins-agent/README.md#Inputs) of the module `jenkins-agent`.
- Step 1-org: The [README](./1-org/envs/shared/README.md#Inputs) of the module `shared`.
- Step 2-environments: The README's of the environments [development](./2-environments/envs/development/README.md#Inputs), [non-production](./2-environments/envs/non-production/README.md#Inputs) and [production](./2-environments/envs/production/README.md#Inputs)
- Step 3-networks: The README's of the environments [development](./3-networks/envs/development/README.md#Inputs), [non-production](./3-networks/envs/non-production/README.md#Inputs) and [production](./3-networks/envs/production/README.md#Inputs)
- Step 4-projects: The README's of the environments [development](./4-projects/business_unit_1/development/README.md#Inputs), [non-production](./4-projects/business_unit_1/non-production/README.md#Inputs) and [production](./4-projects/business_unit_1/production/README.md#Inputs)

## Errata Summary

Refer to the [Errata Summary](./ERRATA.md) for an overview of the delta between the example foundation repository and the [Google Cloud security foundations guide](https://services.google.com/fh/files/misc/google-cloud-security-foundations-guide.pdf).

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for information on contributing to this module.
