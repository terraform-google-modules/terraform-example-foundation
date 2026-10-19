# Partner Interconnect module

This module implements the recommendation proposed in [Establishing 99.99% Availability for Partner Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/partner-creating-9999-availability).

## Prerequisites

1. Provisioning of four [VLAN attachments](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/partner-overview) in the Hub project in the specified environment. That would be the `prj-c-svpc-net-hub` and  `prj-net-dns` under the folder `fldr-common` in case of Hub and Spoke architecture.

## Usage

1. Rename `routers.tf.example` to `routers..tf` in the shared envs folder in `3-networks-hub-and-spoke/envs/shared`
1. Rename `partner_interconnect.tf.example` to `partner_interconnect.tf`in the shared envs folder in `3-networks-hub-and-spoke/envs/shared`.
1. Rename `partner_interconnect.auto.tfvars.example` to `partner_interconnect.auto.tfvars` in the shared envs folder in `3-networks-hub-and-spoke/envs/shared`.
1. Update the file `partner_interconnect.tf` with values that are valid for your environment for the VLAN attachments, locations.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| attachment\_project\_id | The Interconnect Google Cloud project ID. | `string` | n/a | yes |
| ncc\_hub\_group | Network Connectivity Center Group name to attach spokes to. | `string` | n/a | yes |
| ncc\_hub\_uri | The full URI of the existing Network Connectivity Center Hub. | `string` | n/a | yes |
| partner\_interconnect\_config | Partner Interconnect configuration map containing attachment definitions and default settings.<br><br>Top-level attributes:<br>  - preactivate: (Optional) Default preactivate setting for all Partner Interconnect attachments (defaults to false).<br>  - attachments: Map of Partner Interconnect attachment configuration objects keyed by a unique identifier.<br><br>Attachment attributes (map values):<br>  - region:                   Google Cloud region where the attachment and Cloud Router reside.<br>  - router:                   Name or resource ID of the Google Cloud Router to attach to.<br>  - location:                 Google Cloud Interconnect edge location or city code.<br>  - cr\_suffix:                Suffix used for interface naming (e.g., 'cr1', 'cr2').<br>  - edge\_availability\_domain: Edge availability domain assignment ('AVAILABILITY\_DOMAIN\_1', 'AVAILABILITY\_DOMAIN\_2', or 'AVAILABILITY\_DOMAIN\_ANY').<br>  - onprem\_dc:                 (Optional) On-premises data center identifier.<br>  - preactivate:              (Optional) Override preactivate setting for this specific attachment. | <pre>object({<br>    preactivate = optional(bool, false)<br>    attachments = map(object({<br>      region                   = string<br>      router                   = string<br>      location                 = string<br>      cr_suffix                = string<br>      edge_availability_domain = string<br>      onprem_dc                = optional(string)<br>    }))<br>  })</pre> | n/a | yes |
| site\_to\_site\_data\_transfer | Set to true to allow Google Cloud routing to act as a transit network between on-premises sites. | `bool` | `false` | no |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| interconnect\_attachments | Map of all Partner Interconnect attachment objects keyed by attachment identifier. |
| ncc\_spoke\_ids | Map of Network Connectivity Center spoke IDs keyed by region. |
| pairing\_keys | Map of pairing keys for all Partner Interconnect attachments keyed by attachment identifier. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
