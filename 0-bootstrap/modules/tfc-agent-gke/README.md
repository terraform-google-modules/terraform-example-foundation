# Self Hosted Terraform Cloud agent on GKE

This module handles the opinionated creation of infrastructure necessary to deploy Terraform Cloud agents on Google Kubernetes Engine (GKE).

This includes:

- Enabling necessary APIs
- VPC
- GKE Cluster
- Kubernetes Secret

Below are some examples:

## [Simple Terraform Cloud agents on GKE](../../examples/tfc-agent-gke-simple/README.md)

This example shows how to deploy a simple GKE self hosted Terraform Cloud agent.

## [Custom Terraform Cloud agents on GKE](../../examples/tfc-agent-gke-custom/README.md)

This example shows how to deploy a custom Terraform Cloud agent image with GKE.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| create\_network | When set to true, VPC will be auto created | `bool` | `true` | no |
| create\_service\_account | Set to true to create a new service account, false to use an existing one | `bool` | `true` | no |
| ip\_range\_pods\_cidr | The secondary IP range CIDR to use for pods | `string` | `"192.168.0.0/18"` | no |
| ip\_range\_pods\_name | The secondary IP range to use for pods | `string` | `"ip-range-pods"` | no |
| ip\_range\_services\_cider | The secondary IP range CIDR to use for services | `string` | `"192.168.64.0/18"` | no |
| ip\_range\_services\_name | The secondary IP range to use for services | `string` | `"ip-range-scv"` | no |
| machine\_type | Machine type for TFC agent node pool | `string` | `"n1-standard-4"` | no |
| max\_node\_count | Maximum number of nodes in the TFC agent node pool | `number` | `4` | no |
| min\_node\_count | Minimum number of nodes in the TFC agent node pool | `number` | `2` | no |
| network\_name | Name for the VPC network | `string` | `"tfc-agent-network"` | no |
| network\_project\_id | The project ID of the shared VPCs host (for shared vpc support).<br>If not provided, the project\_id is used | `string` | `""` | no |
| project\_id | The Google Cloud Platform project ID to deploy Terraform Cloud agent cluster | `string` | n/a | yes |
| region | The GCP region to use when deploying resources | `string` | `"us-central1"` | no |
| service\_account\_email | Optional Service Account for the GKE nodes, required if create\_service\_account is set to false | `string` | `""` | no |
| subnet\_ip | IP range for the subnet | `string` | `"10.0.0.0/17"` | no |
| subnet\_name | Name for the subnet | `string` | `"tfc-agent-subnet"` | no |
| tfc\_agent\_address | The HTTP or HTTPS address of the Terraform Cloud/Enterprise API | `string` | `"https://app.terraform.io"` | no |
| tfc\_agent\_auto\_update | Controls automatic core updates behavior. Acceptable values include disabled, patch, and minor | `string` | `"minor"` | no |
| tfc\_agent\_cpu\_request | CPU request for the Terraform Cloud agent container | `string` | `"2"` | no |
| tfc\_agent\_image | The Terraform Cloud agent image to use | `string` | `"hashicorp/tfc-agent:latest"` | no |
| tfc\_agent\_k8s\_secrets | Name for the k8s secret required to configure TFC agent on GKE | `string` | `"tfc-agent-k8s-secrets"` | no |
| tfc\_agent\_max\_replicas | Maximum replicas for the Terraform Cloud agent pod autoscaler | `string` | `"10"` | no |
| tfc\_agent\_memory\_request | Memory request for the Terraform Cloud agent container | `string` | `"2Gi"` | no |
| tfc\_agent\_min\_replicas | Minimum replicas for the Terraform Cloud agent pod autoscaler | `string` | `"1"` | no |
| tfc\_agent\_name\_prefix | This name may be used in the Terraform Cloud user interface to help easily identify the agent | `string` | `"tfc-agent-k8s"` | no |
| tfc\_agent\_single | Enable single mode. This causes the agent to handle at most one job and<br>immediately exit thereafter. Useful for running agents as ephemeral<br>containers, VMs, or other isolated contexts with a higher-level scheduler<br>or process supervisor. | `bool` | `false` | no |
| tfc\_agent\_token | Terraform Cloud agent token. (Organization Settings >> Agents) | `string` | n/a | yes |
| zones | The GCP zone to use when deploying resources | `list(string)` | <pre>[<br>  "us-central1-a"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| ca\_certificate | The cluster CA certificate (base64 encoded) |
| client\_token | The bearer token for auth |
| cluster\_name | GKE cluster name |
| kubernetes\_endpoint | The GKE cluster endpoint |
| location | GKE cluster location |
| network\_name | Name of the VPC |
| service\_account | The default service account used for TFC agent nodes |
| subnet\_name | Name of the subnet in the VPC |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

Before this module can be used on a project, you must ensure that the following pre-requisites are fulfilled:

1. Required APIs are activated

    ```text
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "storage-component.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
    ```
