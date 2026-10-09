# Partner Interconnect module

This module implements the recommendation proposed in [Establishing 99.99% Availability for Partner Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/partner-creating-9999-availability) for [Partner Cross-Cloud Interconnect for OCI](https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-cci-for-oci-overview) and [Partner Cross-Cloud Interconnect for AWS](https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-cci-for-aws-overview)

## Prerequisites

1. Provisioning of four [VLAN attachments](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-overview) in the Hub project in the specified environment. That would be the `prj-c-svpc-net-hub` and  `prj-net-dns` under the folder `fldr-common` in case of Hub and Spoke architecture.

## Usage

1. Rename `routers.tf.example` to `routers..tf` in the shared envs folder in `3-networks-hub-and-spoke/envs/shared`
1. Rename `cross_partner_interconnect.tf.example` to `cross_partner_interconnect.tf`in the shared envs folder in `3-networks-hub-and-spoke/envs/shared`.
1. Update the file `cross_partner_interconnect.tf` with values that are valid for your environment for the VLAN attachments, locations.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attachment\_project\_id | the Interconnect project ID. | `string` | n/a | yes |
| ncc\_hub\_group | Network Connectivity Center Group to attach the spoke to | `string` | n/a | yes |
| ncc\_hub\_uri | The full URI (ID) of the existing Network Connectivity Center Hub where the spokes will be attached. | `string` | n/a | yes |
| partner\_cross\_cloud\_config | Partner Cross-Cloud Interconnect configuration containing remote provider settings and attachment definitions.<br><br>Top-level attributes:<br>  - remote\_cloud\_provider: Target cloud provider. Must be either 'aws' or 'oci'.<br>  - attachments:           Map of Partner Interconnect attachment configuration objects keyed by a unique identifier.<br><br>Attachment attributes (map values):<br>  - region:                   Google Cloud region where the attachment and Cloud Router reside (e.g., 'us-central1').<br>  - router:                   Name or resource reference of the Google Cloud Router to attach to.<br>  - cross\_dc:                 Identifier for the remote cloud data center or facility location (e.g., 'aws-partner-dc1').<br>  - location:                 Google Cloud Interconnect edge location code or city code (e.g., 'iad').<br>  - cr\_suffix:                Suffix identifier used when constructing Cloud Router interface and subinterface names (e.g., 'cr1').<br>  - edge\_availability\_domain: Edge availability domain assignment. Must be 'AVAILABILITY\_DOMAIN\_1', 'AVAILABILITY\_DOMAIN\_2', or 'AVAILABILITY\_DOMAIN\_ANY'.<br>  - preactivate:              (Optional) Whether to preactivate the attachment before the partner completes pairing (defaults to false). | <pre>object({<br>    remote_cloud_provider = string<br>    attachments = map(object({<br>      region                   = string<br>      router                   = string<br>      cross_dc                 = string<br>      location                 = string<br>      cr_suffix                = string<br>      edge_availability_domain = string<br>      preactivate              = optional(bool, false)<br>    }))<br>  })</pre> | n/a | yes |
| region1 | First subnet region. The Partner Interconnect module only configures two regions. | `string` | n/a | yes |
| region2 | Second subnet region. The Partner Interconnect module only configures two regions. | `string` | n/a | yes |
| site\_to\_site\_data\_transfer | Set to true to allow Google Cloud routing to act as a transit network between on-premises sites. | `bool` | `false` | no |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| customer\_router\_ip\_addresses | Map of IPv4 addresses + prefix lengths to configure on customer router subinterfaces. |
| interconnect\_attachments | Map of all partner interconnect attachment objects keyed by attachment name. |
| partner\_asns | Map of partner ASNs assigned to each Partner Interconnect attachment. |
| partner\_pairing\_keys | Pairing keys generated for Partner Interconnect provisioning. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
