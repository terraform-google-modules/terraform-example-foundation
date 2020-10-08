## How to write your own custom constraint templates

This document is for advanced users who wish to create custom constraint
templates.

**Table of Contents**

* [Template Authoring Convention](#template-authoring-convention)
  * [Naming](#naming)
  * [Commentary](#commentary)
* [Validate your constraint goals and target resources](#validate-your-constraint-goals-and-target-resources)
* [Gather sample resource data](#gather-sample-resource-data)
* [Write Rego rule for constraint template](#write-rego-rule-for-constraint-template)
* [Write constraint and resource fixtures for your constraint template](#write-constraint-and-resource-fixtures-for-your-constraint-template)
* [Write Rego tests for your rule](#write-rego-tests-for-your-rule)
* [Create constraint template YAML definition](#create-constraint-template-yaml-definition)
* [Contact Info](#contact-info)

### Template Authoring Convention

#### Naming

The template name appears in three places in a template YAML file:

*   metadata name: All lower case with "-" as the separator. It has the format
    of "gcp-{resource}-{feature}-{version}" (example: "gcp-storage-logging-v1").
*   CRD kind (under "spec" > "crd" > "spec" > "names" > "kind"): Camel case. It
    has the format of "GCP{resource}{feature}Constraint{version}" (example:
    "GCPStorageLoggingConstraintV1").

Wherever possible, follow [gcloud](https://cloud.google.com/sdk/gcloud/) group
names for resource naming. For example, use "compute" instead of "gce", "sql"
instead of "cloud-sql", and "container-cluster" instead of "gke".

If a template applies to more than one type of resource, omit the resource part
and only include the feature (example: "GCPExernalIPAccessV1").

The version number does not follow semver form - it is just a single number.
This effectively makes every version of a template an unique template. See
[Constraint Framework: Versioning](https://docs.google.com/document/d/1vB_2wm60WCVLXoegMrupqwqKAuW6gbwEIxg3vBQj6cs/edit#)
for reasons behind this convention.

The configuration YAML file name should take after the metadata name and replace
"-" with "_" (example: "gcp_storage_logging_v1.yaml").

#### Commentary

Every configuration YAML file should have a summary at the top to describe the
constraint. In the parameters section, every parameter should include a
[description](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md#properties)
field to explain what the parameter does.

### Validate your constraint goals and target resources

Before beginning to develop your constraint template, you should write a
concrete definition of your goals in plain language. In writing this definition,
clearly define what resources you're looking to scan or analyze, and what
properties of those resources you plan to constrain.

For example:

```
The External IP Access Constraint will scan GCP VM instances and validate that the Access Config of their network interface does not include an external IP address.
```

### Gather sample resource data

Before proceeding to develop your template, you should verify that Cloud Asset
Inventory
[supports](https://cloud.google.com/resource-manager/docs/cloud-asset-inventory/overview#supported_resource_types)
the resources you want. Assuming it does, you should gather some sample data to
use in developing and testing your rule by creating resources of the appropriate
type and creating a CAI export of those resources (see
[CAI quickstart](https://cloud.google.com/resource-manager/docs/cloud-asset-inventory/quickstart-cloud-asset-inventory)).
If the desired resource is not supported, please open a GitHub issue and/or
email validator-support@google.com.

For example, you might gather the following JSON export for external IP address
constraint (for brevity, most fields are omitted). In the same data below, the
presence of the `externalIp` field indicates that an external IP address is
assigned to the VM.

```
[
  {
    "name": "//compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/vm",
    "asset_type": "google.compute.Instance",
    "resource": {
      "version": "v1",
      "discovery_document_uri": "https://www.googleapis.com/discovery/v1/apis/compute/v1/rest",
      "discovery_name": "Instance",
      "parent": "//cloudresourcemanager.googleapis.com/projects/68478495408",
      "data": {
        "name": "vm-external-ip",
        "networkInterfaces": [
          {
            "accessConfigs": [
              {
                "externalIp": "35.196.151.107",
                "name": "external-nat",
                "networkTier": "PREMIUM",
                "type": "ONE_TO_ONE_NAT"
              }
            ],
            "fingerprint": "FKYLBaTiCF0=",
            "ipAddress": "10.142.0.2",
            "name": "nic0",
            "network": "https://www.googleapis.com/compute/v1/projects/test-project/global/networks/default",
            "subnetwork": "https://www.googleapis.com/compute/v1/projects/test-project/regions/us-east1/subnetworks/default"
          }
        ],
      }
    }
  },
]
```

### Write Rego rule for constraint template

In order to develop a constraint template, you must develop a Rego rule to back
it. Before you begin, read about
[how to write policies](https://www.openpolicyagent.org/docs/how-do-i-write-policies.html)
using Rego and Open Policy Agent.

To store a rule for your constraint template, create a new Rego file (for
example, <code><em>vm_external_ip.rego</em></code>). This file should include a
single <code><em>deny</em></code> rule which returns violations by evaluating
whether a given <code><em>input.asset</em></code> violates the constraint
provided in <code><em>input.constraint</em></code>.

As you develop the Rego rule, keep these principles in mind:

*   Logic can be externalized into additional rules and functions which should
    be defined below the deny rule in a utilities section.
*   If your rule only applies to particular resource types, you should check
    that the given <code><em>input.asset</em></code> is of the required type
    early on. (for example, <code><em>input.asset.asset_type ==
    "google.compute.Instance"</em></code>).
*   If your rule requires input parameters, they will be present under
    <code>input.constraint</code>. You can retrieve it using the library
    function <code>get_constraint_params</code> in the
    <code>data.validator.gcp.lib</code> package.
*   Comments should be included for any complicated logic and all helper
    functions and rules should have a comment explaining their intent.
*   Equality comparison should be done using <code><em>==</em></code> to
    differentiate it from assignment.
*   A violation is generated only when the rule body evaluates to true. In other
    words, you should look for the negative condition.
*   There are helpful functions available in the GCP library which you can
    import into your rule. For example, <code><em>import data.validator.gcp.lib
    as lib</em></code>.

For example, this rule checks whether a VM with external IP address should be
exempted (allowlist) or treated as a violation (denylist):

```
package validator.gcp.GCPExternalIpAccessConstraintV1
import data.validator.gcp.lib as lib

deny[{
        "msg": message,
        "details": metadata,
}] {
        constraint := input.constraint
        lib.get_constraint_params(constraint, params)
        asset := input.asset
        asset.asset_type == "google.compute.Instance"
        # Find network access config block w/ external IP
        instance := asset.resource.data
        access_config := instance.networkInterface[_].accessConfig
        external_ip := access_config[_].externalIp
        # Check if instance is in allowlist/denylist
        target_instances := params.instances
        matches := {asset.name} & cast_set(target_instances)
        target_instance_match_count(params.mode, desired_count)
        count(matches) == desired_count
        message := sprintf("%v is not allowed to have an external IP.", [asset.name])
        metadata := {"external_ip": external_ip}
}

# Determine the overlap between instances under test and constraint
# By default (allowlist), we violate if there isn't overlap
target_instance_match_count(mode) = 0 {
        mode != "denylist"
}
target_instance_match_count(mode) = 1 {
        mode == "denylist"
}
```

### Write constraint and resource fixtures for your constraint template

To test your rule, create fixtures of the expected resources and constraints
leveraging your rule. To implement your test cases, gather resource fixtures
from CAI and place them in a
<code><em>test/fixtures/resources/<resource_type>/data.json</em></code> file.
You can also write a constraint fixture using your constraint template and place
it in
<code><em>test/fixtures/constraints/<constraint_name/data.yaml</em></code>.

For example, here is a sample constraint used for external IP rule:

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
      - //compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/vm-external-ip
```

The rule above says that the external IP constraint applies to all
organizations, but the GCE instance `vm-external-ip` under `test-project` in
`us-east1-b` is exempt.

### Write Rego tests for your rule

As you develop your constraint template, implement test cases that ensure your
logic doesn't break over time. Open Policy Agent allows you to
[implement simple tests](https://www.openpolicyagent.org/docs/how-do-i-test-policies.html)
by prefixing rules with `test_`.

Using the fixtures you have gathered, write tests in a Rego file named after
your rule. For example, <code><em>vm_external_ip_test.rego</em></code>. Make
sure to place this Rego file in the same package as your rule with the
<code>package</code> definition. One useful pattern is to write a rule which
gathers all violations for your test cases and additional <code>test_</code>
rules which verify those violations.

For example, here are the tests for the above external IP constraint:

```
package validator.gcp.GCPExternalIpAccessConstraintV1

import data.test.fixtures.assets.compute_instances as fixture_instances
import data.test.fixtures.constraints as fixture_constraints

# Find all violations on our test cases
find_violations[violation] {
        instance := data.instances[_]
        constraint := data.test_constraints[_]
        issues := deny with input.asset as instance
                 with input.constraint as constraint
        total_issues := count(issues)
        violation := issues[_]
}

allowlist_violations[violation] {
        constraints := [fixture_constraints.forbid_external_ip_allowlist]
        found_violations := find_violations with data.instances as fixture_instances
                 with data.test_constraints as constraints
        violation := found_violations[_]
}

# Confirm only a single violation was found (allowlist constraint)
test_external_allowlist_ip_violates_one {
        found_violations := allowlist_violations
        count(found_violations) = 1
        violation := found_violations[_]
        resource_name := "//compute.googleapis.com/projects/test-project/zones/us-east1-b/instances/vm-external-ip"
        is_string(violation.msg)
        is_object(violation.details)
}

```

### Create constraint template YAML definition

Once you have a working Rego rule, you are ready to package it into a constraint
template. You can do this by writing a YAML file which defines the expected
parameters and logic for constraints. Create this file from the template, and
then input the contents of your Rego rule.

This example shows the external IP constraint template, with the italicized
portions changing for your template:

```
apiVersion: templates.gatekeeper.sh/v1alpha1
kind: ConstraintTemplate
metadata:
  name: gcp-external-ip-access
  annotations:
    # Example of tying a template to a CIS benchmark
    benchmark: CIS11_5.03
spec:
  crd:
    spec:
      names:
        kind: GCPExternalIpAccessConstraintV1
      validation:
        openAPIV3Schema:
          properties:
            mode:
              type: string
              enum: [denylist, allowlist]
            instances:
              type: array
              items: string
  targets:
   validation.gcp.forsetisecurity.org:
      rego: |
            #INLINE("validator/vm_external_ip.rego")
            #ENDINLINE
```

The Rego rule is supposed to be inlined in the YAML file. To do that, run `make
build`. That will format the rego rules and inline them in the YAML files under
the `#INLINE` directive.

### Contact Info

Questions or comments? Please contact validator-support@google.com.
