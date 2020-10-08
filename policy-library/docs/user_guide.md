## Config Validator | Setup & User Guide

### Go from setup to proof-of-concept in under 1 hour

**Table of Contents**

* [Overview](#overview)
* [How to set up constraints with Policy Library](#how-to-set-up-constraints-with-policy-library)
  * [Get started with the Policy Library repository](#get-started-with-the-policy-library-repository)
  * [Instantiate constraints](#instantiate-constraints)
* [How to use Terraform Validator](#how-to-use-terraform-validator)
  * [Install Terraform Validator](#install-terraform-validator)
  * [For local development environments](#for-local-development-environments)
  * [For Production Environments](#for-production-environments)
* [How to Use Forseti Config Validator](#how-to-use-forseti-config-validator)
  * [Deploy Forseti](#deploy-forseti)
  * [Policy Library Sync from Git Repository](https://forsetisecurity.org/docs/latest/configure/config-validator/policy-library-sync-from-git-repo.html)
  * [Policy Library Sync from GCS](https://forsetisecurity.org/docs/latest/configure/config-validator/policy-library-sync-from-gcs.html)
* [End to end workflow with sample constraint](#end-to-end-workflow-with-sample-constraint)
* [Contact Info](#contact-info)

## Overview

As your business shifts towards an infrastructure-as-code workflow, security and
cloud administrators are concerned about misconfigurations that may cause
security and governance violations.

Cloud Administrators need to be able to put up guardrails that follow security
best practices and help drive the environment towards programmatic security and
governance while enabling developers to go fast.

Config Validator allows your administrators to enforce constraints that validate
whether deployments can be provisioned while still enabling developers to move
quickly within these safe guardrails. Validator accomplishes this through a
three key components:

**One way to define constraints**

Constraints are defined so that they can work across an ecosystem of
pre-deployment and monitoring tools. These constraints live in your
organization's repository as the source of truth for your security and
governance requirements. You can obtain constraints from the
[Policy Library](#how-to-set-up-constraints-with-policy-library), or
[build your own constraint templates](constraint_template_authoring.md).

**Pre-deployment check**

Check for constraint violations during pre-deployment and provide warnings or
halt invalid deployments before they reach production. The pre-deployment logic
that Config Validator uses will be built into a number of deployment tools. For
details, [check out Terraform Validator](#how-to-use-terraform-validator).

**Ongoing monitoring**

Frequently scan the platform for constraint violations and send notifications
when a violation is found. The monitoring logic that Config Validator uses will
be built into a number of monitoring tools. For details,
[check out Forseti Validator](#how-to-use-forseti-config-validator).

The following guide will walk you through initial setup steps and instructions
on how to use Config Validator. By the end, you will have a proof-of-concept to
experiment with and to build your foundation upon.

## How to set up constraints with Policy Library

### Get started with the Policy Library repository

The Policy Library repository contains the following directories:

*   `policies`
    *   `constraints`: This is initially empty. You should place your constraint
        files here.
    *   `templates`: This directory contains pre-defined constraint templates.
*   `validator`: This directory contains the `.rego` files and their associated
    unit tests. You do not need to touch this directory unless you intend to
    modify existing constraint templates or create new ones. Running `make
    build` will inline the Rego content in the corresponding constraint template
    files.

Google provides a sample repository with a set of pre-defined constraint
templates. You can duplicate this repository into a private repository. First
you should create a new **private** git repository. For example, if you use
GitHub then you can use the [GitHub UI](https://github.com/new). Then follow the
steps below to get everything setup. If you are planning on using the [Policy
Library Sync feature of Forseti](#policy-library-sync), then you should also add
a read-only user to the private repository which will be used by Forseti.

This policy library can also be made public, but it is not recommended. By
making your policy library public, it would be allowing others to see what you
are and __ARE NOT__ scanning for.

#### Duplicate Policy Library Repository

To run the following commands, you will need to configure git to connect
securely. It is recommended to connect with SSH. [Here is a helpful resource](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh) for learning about how
this works, including steps to set this up for GitHub repositories; other
providers offer this feature as well.

```
export GIT_REPO_ADDR="git@github.com:${YOUR_GITHUB_USERNAME}/policy-library.git"
git clone --bare https://github.com/forseti-security/policy-library.git
cd policy-library.git
git push --mirror ${GIT_REPO_ADDR}
cd ..
rm -rf policy-library.git
git clone ${GIT_REPO_ADDR}
```

#### Setup Constraints

Then you need to examine the available constraint templates inside the
`templates` directory. Pick the constraint templates that you wish to use,
create constraint YAML files corresponding to those templates, and place them
under `policies/constraints`. Commit the newly created constraint files to
**your** Git repository. For example, assuming you have created a Git repository
named "policy-library" under your GitHub account, you can use the following
commands to perform the initial commit:

```
cd policy-library
# Add new constraints...
git add --all
git commit -m "Initial commit of policy library constraints"
git push -u origin master
```

#### Pull in latest changes from Public Repository

Periodically you should pull any changes from the public repository, which might
contain new templates and Rego files.

```
git remote add public https://github.com/forseti-security/policy-library.git
git pull public master
git push origin master
```

### Instantiate constraints

The constraint template library only contains templates. Templates specify the
constraint logic, and you must create constraints based on those templates in
order to enforce them. Constraint parameters are defined as YAML files in the
following format:

```
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: # place constraint template kind here
metadata:
  name: # place constraint name here
spec:
  severity: # low, medium, or high
  match:
    target: [] # put the constraint application target here
    exclude: [] # optional, default is no exclusions
  parameters: # put the parameters defined in constraint template here
```

The <code><em>target</em></code> field is specified in a path-like format. It
specifies where in the GCP resources hierarchy the constraint is to be applied.
For example:

<table>
  <tr>
   <td>Target
   </td>
   <td>Description
   </td>
  </tr>
  <tr>
   <td>organizations/**
   </td>
   <td>All organizations
   </td>
  </tr>
  <tr>
   <td>organizations/123/**
   </td>
   <td>Everything in organization 123
   </td>
  </tr>
  <tr>
   <td>organizations/123/folders/**
   </td>
   <td>Everything in organization 123 that is under a folder
   </td>
  </tr>
  <tr>
   <td>organizations/123/folders/456
   </td>
   <td>Everything in folder 456 in organization 123
   </td>
  </tr>
  <tr>
   <td>organizations/123/folders/456/projects/789
   </td>
   <td>Everything in project 789 in folder 456 in organization 123
   </td>
  </tr>
</table>

The <code><em>exclude</em></code> field follows the same pattern and has
precedence over the <code><em>target</em></code> field. If a resource is in
both, it will be excluded.

The schema of the <code><em>parameters</em></code> field is defined in the
constraint template, using the
[OpenAPI V3](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#schemaObject)
schema. This is the same validation schema in Kubernetes's custom resource
definition. Every template contains a <code><em>validation</em></code> section
that looks like the following:

```
validation:
  openAPIV3Schema:
    properties:
      mode:
        type: string
      instances:
        type: array
        items: string
```

According to the template above, the parameter field in the constraint file
should contain a string named `mode` and a string array named
<code><em>instances</em></code>. For example:

```
parameters:
  mode: allowlist
  instances:
    - //compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/one
    - //compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/two
```

These parameters specify that two VM instances may have external IP addresses.
The are exempt from the constraint since they are allowlisted.

Here is a complete example of a sample external IP address constraint file:

```
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPExternalIpAccessConstraintV1
metadata:
  name: forbid-external-ip-allowlist
spec:
  severity: high
  match:
    target: ["organizations/**"]
  parameters:
    mode: "allowlist"
    instances:
    - //compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/one
    - //compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/two
```

## How to use Terraform Validator

### Install Terraform Validator

The released binaries are available under the `gs://terraform-validator` Google
Cloud Storage bucket for Linux, Windows, and Mac. They are organized by release
date, for example:

```
$ gsutil ls -r gs://terraform-validator/releases
...
gs://terraform-validator/releases/2019-04-04/terraform-validator-darwin-amd64
gs://terraform-validator/releases/2019-04-04/terraform-validator-linux-amd64
gs://terraform-validator/releases/2019-04-04/terraform-validator-windows-amd64
```

To download the binary, you need to
[install](https://cloud.google.com/storage/docs/gsutil_install#install) the
`gsutil` tool first. The following command downloads the Linux version of
Terraform Validator from 2019-04-04 release to your local directory:

```
gsutil cp gs://terraform-validator/releases/2019-04-04/terraform-validator-linux-amd64 .
chmod 755 terraform-validator-linux-amd64
```

### For local development environments

Currently only Terraform v0.11 is supported.
These instructions assume you have forked a branch and is working locally.

Generate a Terraform plan for the current environment by running:

```
terraform plan -out=tfplan.tfplan
```

To validate the Terraform plan based on the constraints specified under your
local policy library repository, run:

```
terraform-validator-linux-amd64 validate tfplan.tfplan --policy-path=${POLICY_PATH}
```

The policy-path flag is set to the local clone of your Git repository that
contains the constraints and templates. This is described in the
["How to set up constraints with Policy Library"](#how-to-set-up-constraints-with-policy-library)
section.

Terraform Validator also accepts an optional --project flag which is set to the
Terraform Google provider project. See the
[provider docs](https://www.terraform.io/docs/providers/google/index.html) for
more info. If it is not set, Terraform Validator will attempt to parse the
provider project from the provider configuration.

If violations are found, a list will be returned of the affected resources and a
brief message about the violations:

```
Found Violations:

Constraint iam_domain_restriction on resource //cloudresourcemanager.googleapis.com/projects/299388503561: IAM policy for //cloudresourcemanager.googleapis.com/projects/299388503561 contains member from unexpected domain: user:foo@example.com

Constraint iam_domain_restriction on resource //cloudresourcemanager.googleapis.com/projects/299388503561: IAM policy for //cloudresourcemanager.googleapis.com/projects/299388503561 contains member from unexpected domain: group:bar@example.com
```

If all constraints are validated, the command will return "`No violations
found`." You can then apply a plan locally on a development environment:

```
terraform apply
```

### For Production Environments

These instructions assume that the developer has merged their local branch back
with master. We want to make sure the master deployment into production is
validated.

In your continuous integration (CI) tool, you should install Terraform
validator. Then you can add a step to any workflow which will validate a
Terraform plan and reject it if violations are found. Terraform validator will
return a `2` exit code if violations are found or `0` if no violations were
found. Therefore, you should configure your CI to only proceed to the next step
(for example, `terraform apply`) or merge if the validator exits successfully.

## How to Use Forseti Config Validator

### Deploy Forseti

Follow the [documentation on the Forseti Security website](https://forsetisecurity.org/docs/latest/setup/install/index.html)
to deploy Forseti on GCE. As part of the Terraform configuration, you will need to enable
Config Validator. Follow the [documentation on the Forseti Security website](https://forsetisecurity.org/docs/latest/configure/config-validator/index.html)
to set up Config Validator.

#### Provide Policies to Forseti Server

The recommended practice is to store the Policy Library in a VCS such as GitHub
or other git repository. This supports the idea of policy as code and requires
work to setup the repository and connect it with Forseti. Once the repository is
setup, then Forseti will automatically
[sync](https://github.com/kubernetes/git-sync) policy updates to the Forseti
Server to be used by future scans.

The default behavior of Forseti is to sync the Policy Library from the Forseti
Server GCS bucket. This requires little setup, but involves manual work to
create the folder and copy the policies to GCS. 

Follow the documentation on the Forseti Security website to sync policies
from the [GCS to the Forseti server](https://forsetisecurity.org/docs/latest/configure/config-validator/policy-library-sync-from-gcs.html), and from [Git Repository to the Forseti server](https://forsetisecurity.org/docs/latest/configure/config-validator/policy-library-sync-from-git-repo.html).

## End to end workflow with sample constraint

In this section, you will apply a constraint that enforces IAM policy member
domain restriction using [Cloud Shell](https://cloud.google.com/shell/).

First click on this
[link](https://console.cloud.google.com/cloudshell/open?cloudshell_image=gcr.io/graphite-cloud-shell-images/terraform:latest&cloudshell_git_repo=https://github.com/forseti-security/policy-library.git)
to open a new Cloud Shell session. The Cloud Shell session has Terraform
pre-installed and the Policy Library repository cloned. Once you have the
session open, the next step is to copy over the sample IAM domain restriction
constraint:

```
cp policy-library/samples/iam_service_accounts_only.yaml policy-library/policies/constraints
```

Let's take a look at this constraint:

```
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPIAMAllowedPolicyMemberDomainsConstraintV1
metadata:
  name: service_accounts_only
spec:
  severity: high
  match:
    target: ["organizations/**"]
  parameters:
    domains:
      - gserviceaccount.com
```

It specifies that only members from gserviceaccount.com domain can be present in
an IAM policy. To verify that it works, let's attempt to create a project.
Create the following Terraform `main.tf` file:

```
provider "google" {
  version = "~> 1.20"
  project = "your-terraform-provider-project"
}

resource "random_id" "proj" {
  byte_length = 8
}

resource "google_project" "sample_project" {
  project_id      = "validator-${random_id.proj.hex}"
  name            = "config validator test project"
}

resource "google_project_iam_binding" "sample_iam_binding" {
  project = "${google_project.sample_project.project_id}"
  role    = "roles/owner"

  members = [
    "user:your-email@your-domain"
  ]
}

```

Make sure to specify your Terraform
[provider project](https://www.terraform.io/docs/providers/google/getting_started.html)
and email address. Then initialize Terraform and generate a Terraform plan:

```
terraform init
terraform plan -out=test.tfplan
```

Since your email address is in the IAM policy binding, the plan should result in
a violation. Let's try this out:

```
gsutil cp gs://terraform-validator/releases/2019-03-28/terraform-validator-linux-amd64 .
chmod 755 terraform-validator-linux-amd64
./terraform-validator-linux-amd64 validate test.tfplan --policy-path=policy-library
```

The Terraform validator should return a violation. As a test, you can relax the
constraint to make the violation go away. Edit the
`policy-library/policies/constraints/iam_service_accounts_only.yaml` file and
append your email domain to the domains allowlist:

```
apiVersion: constraints.gatekeeper.sh/v1alpha1
kind: GCPIAMAllowedPolicyMemberDomainsConstraintV1
metadata:
  name: service_accounts_only
spec:
  severity: high
  match:
    target: ["organizations/**"]
  parameters:
    domains:
      - gserviceaccount.com
      - your-domain-here
```

Then run Terraform plan and validate the output again:

```
terraform plan -out=test.tfplan
./terraform-validator-linux-amd64 validate test.tfplan --policy-path=policy-library
```

The command above should result in no violations found.

## Contact Info

Questions or comments? Please contact validator-support@google.com.
