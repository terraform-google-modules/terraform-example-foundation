# Dedicated interconnecte module

This module implementes the recomendation proposed in [Establishing 99.99% Availability for Dedicated Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/dedicated-creating-9999-availability).

## Prerequisites

1. Execution of at least one of the environments in `3-networks/env/`.
1. Creation on two Cloud Routers for each Region. Both the `Restricted shared VPC` and the `Standard shared VPC` modules create two Cloud Routers for each Region that should be used as input for this module. **This module only works with two regions.**
1. Provisioning of four [dedicated interconnects](https://cloud.google.com/network-connectivity/docs/interconnect/concepts/dedicated-overview) in the `prj-interconnect` project created in step `1-org` under folder `fldr-common`.

## Usage

Sections with examples of calls to this module are commented in each one of the environments. Uncomment these section and update the input values with your interconnects and peer BGP information and rerun Terraform.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| peer\_asn | Peer BGP Autonomous System Number (ASN). | number | n/a | yes |
| peer\_ip\_address | IP address of the BGP interface outside Google Cloud Platform. Only IPv4 is supported. | string | n/a | yes |
| peer\_name | Name of this BGP peer. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? | string | n/a | yes |
| region1 | First subnet region. The dedicated Interconnect module only configures two regions. | string | n/a | yes |
| region1\_interconnect1 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| region1\_interconnect1\_location | Name of the interconnect location used in the creation of the Interconnect for the first location of region1 | string | n/a | yes |
| region1\_interconnect2 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| region1\_interconnect2\_location | Name of the interconnect location used in the creation of the Interconnect for the second location of region1 | string | n/a | yes |
| region1\_router1\_name | Name of the Router 1 for Region 1 where the attachment resides. | string | n/a | yes |
| region1\_router2\_name | Name of the Router 2 for Region 1 where the attachment resides. | string | n/a | yes |
| region2 | Second subnet region. The dedicated Interconnect module only configures two regions. | string | n/a | yes |
| region2\_interconnect1 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| region2\_interconnect1\_location | Name of the interconnect location used in the creation of the Interconnect for the first location of region2 | string | n/a | yes |
| region2\_interconnect2 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| region2\_interconnect2\_location | Name of the interconnect location used in the creation of the Interconnect for the second location of region2 | string | n/a | yes |
| region2\_router1\_name | Name of the Router 1 for Region 2 where the attachment resides. | string | n/a | yes |
| region2\_router2\_name | Name of the Router 2 for Region 2 where the attachment resides | string | n/a | yes |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| interconnect\_attachment1\_region1 | The created attachment |
| interconnect\_attachment1\_region1\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |
| interconnect\_attachment1\_region2 | The created attachment |
| interconnect\_attachment1\_region2\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |
| interconnect\_attachment2\_region1 | The created attachment |
| interconnect\_attachment2\_region1\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |
| interconnect\_attachment2\_region2 | The created attachment |
| interconnect\_attachment2\_region2\_customer\_router\_ip\_address | IPv4 address + prefix length to be configured on the customer router subinterface for this interconnect attachment. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
