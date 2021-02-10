# Dedicated Interconnect module

This module implements the recommendation proposed in [Establishing 99.99% Availability for Dedicated Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/dedicated-creating-9999-availability).

## Prerequisites

1. Provisioning of four [Dedicated Interconnect connections](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/dedicated-overview) in the `prj-interconnect` project created in step `1-org` under folder `fldr-common`.

## Usage

1. Rename `interconnect.tf.example` to `interconnect.tf` in the environment folder in `3-networks/envs/<environment>`
1. Update the file `interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.
1. The candidate subnetworks and vlan_tag8021q variables can be set to `null` to allow the interconnect module to auto generate these values.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_router\_labels | A map of suffixes for labelling vlans with four entries like "vlan\_1" => "suffix1" with keys from `vlan_1` to `vlan_4`. | `map(string)` | `{}` | no |
| folder\_prefix | Name prefix to use for folders created. | `string` | `"fldr"` | no |
| org\_id | Organization ID | `string` | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | `string` | `""` | no |
| peer\_asn | Peer BGP Autonomous System Number (ASN). | `number` | n/a | yes |
| peer\_name | Name of this BGP peer. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]\*[a-z0-9])? | `string` | n/a | yes |
| region1 | First subnet region. The Dedicated Interconnect module only configures two regions. | `string` | n/a | yes |
| region1\_interconnect1 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | `string` | n/a | yes |
| region1\_interconnect1\_candidate\_subnets | Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc). | `list(string)` | `null` | no |
| region1\_interconnect1\_location | Name of the interconnect location used in the creation of the Interconnect for the first location of region1 | `string` | n/a | yes |
| region1\_interconnect1\_vlan\_tag8021q | The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094. | `string` | `null` | no |
| region1\_interconnect2 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | `string` | n/a | yes |
| region1\_interconnect2\_candidate\_subnets | Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc). | `list(string)` | `null` | no |
| region1\_interconnect2\_location | Name of the interconnect location used in the creation of the Interconnect for the second location of region1 | `string` | n/a | yes |
| region1\_interconnect2\_vlan\_tag8021q | The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094. | `string` | `null` | no |
| region1\_router1\_name | Name of the Router 1 for Region 1 where the attachment resides. | `string` | n/a | yes |
| region1\_router2\_name | Name of the Router 2 for Region 1 where the attachment resides. | `string` | n/a | yes |
| region2 | Second subnet region. The Dedicated Interconnect module only configures two regions. | `string` | n/a | yes |
| region2\_interconnect1 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | `string` | n/a | yes |
| region2\_interconnect1\_candidate\_subnets | Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc). | `list(string)` | `null` | no |
| region2\_interconnect1\_location | Name of the interconnect location used in the creation of the Interconnect for the first location of region2 | `string` | n/a | yes |
| region2\_interconnect1\_vlan\_tag8021q | The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094. | `string` | `null` | no |
| region2\_interconnect2 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | `string` | n/a | yes |
| region2\_interconnect2\_candidate\_subnets | Up to 16 candidate prefixes that can be used to restrict the allocation of cloudRouterIpAddress and customerRouterIpAddress for this attachment. All prefixes must be within link-local address space (169.254.0.0/16) and must be /29 or shorter (/28, /27, etc). | `list(string)` | `null` | no |
| region2\_interconnect2\_location | Name of the interconnect location used in the creation of the Interconnect for the second location of region2 | `string` | n/a | yes |
| region2\_interconnect2\_vlan\_tag8021q | The IEEE 802.1Q VLAN tag for this attachment, in the range 2-4094. | `string` | `null` | no |
| region2\_router1\_name | Name of the Router 1 for Region 2 where the attachment resides. | `string` | n/a | yes |
| region2\_router2\_name | Name of the Router 2 for Region 2 where the attachment resides | `string` | n/a | yes |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| interconnect\_attachment1\_region1 | The interconnect attachment 1 for region 1 |
| interconnect\_attachment1\_region1\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |
| interconnect\_attachment1\_region2 | The interconnect attachment 1 for region 2 |
| interconnect\_attachment1\_region2\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |
| interconnect\_attachment2\_region1 | The interconnect attachment 2 for region 1 |
| interconnect\_attachment2\_region1\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |
| interconnect\_attachment2\_region2 | The interconnect attachment 2 for region 2 |
| interconnect\_attachment2\_region2\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
