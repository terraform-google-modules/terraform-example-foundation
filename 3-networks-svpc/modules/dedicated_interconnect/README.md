# Dedicated Interconnect module

This module implements the recommendation proposed in [Establishing 99.99% Availability for Dedicated Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/dedicated-creating-9999-availability).

## Prerequisites

1. Provisioning of four [Dedicated Interconnect connections](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/dedicated-overview) in the `prj-interconnect` project created in step `1-org` under folder `fldr-common`.

## Usage

1. Rename `routers.tf.example` to `routers.tf` in the base-env folder in `3-networks-svpc/modules/base_env`
1. Rename `interconnect.tf.example` to `interconnect.tf` in base_env folder in `3-networks-svpc/modules/base_env`.
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. The candidate subnetworks and vlan_tag8021q variables can be set to `null` to allow the interconnect module to auto generate these values.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| dedicated\_interconnect\_config | Dedicated Interconnect configuration map and default settings.<br><br>Top-level attributes:<br>  - peer\_asn:   (Optional) Default BGP Autonomous System Number (ASN) of the on-premises peer.<br>  - peer\_name:  (Optional) Default name for the on-premises BGP peer.<br>  - attachments: Map of Dedicated Interconnect attachment objects keyed by a unique identifier.<br><br>Attachment attributes (map values):<br>  - region:            Google Cloud region where the attachment and Cloud Router reside.<br>  - router:            Name of the Google Cloud Router.<br>  - onprem\_dc:         Identifier for the on-premises data center (e.g., 'equinix-dc1').<br>  - location:          Google Cloud Interconnect edge location code (e.g., 'iad-zone1-1').<br>  - cr\_suffix:         Suffix used for interface/subinterface naming (e.g., 'cr5', 'cr6').<br>  - interconnect:      Resource URL or ID of the physical Dedicated Interconnect port.<br>  - candidate\_subnets: (Optional) Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc).<br>  - vlan\_tag8021q:     (Optional) The IEEE 802.1Q VLAN tag for this attachment, in the range (2-4094). | <pre>object({<br>    peer_asn  = optional(number)<br>    peer_name = optional(string)<br>    attachments = map(object({<br>      region            = string<br>      router            = string<br>      onprem_dc         = string<br>      location          = string<br>      cr_suffix         = string<br>      interconnect      = string<br>      candidate_subnets = optional(list(string))<br>      vlan_tag8021q     = optional(number)<br>    }))<br>  })</pre> | n/a | yes |
| enable\_site\_to\_site\_data\_transfer | Set to true to enable site-to-site data transfer on NCC spokes. | `bool` | `false` | no |
| interconnect\_project\_id | Interconnect project ID. | `string` | n/a | yes |
| ncc\_hub\_group | Network Connectivity Center Group name to attach spokes to. | `string` | n/a | yes |
| ncc\_hub\_uri | The full URI of the existing Network Connectivity Center Hub. | `string` | n/a | yes |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| customer\_router\_ip\_addresses | Map of customer router IP addresses for all attachments keyed by attachment identifier. |
| google\_cloud\_router\_ip\_addresses | Map of Google Cloud Router BGP IP addresses for all attachments keyed by attachment identifier. |
| interconnect\_attachments | Map of all Dedicated Interconnect attachment objects keyed by attachment identifier. |
| ncc\_spoke\_ids | Map of Network Connectivity Center spoke IDs keyed by region. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
