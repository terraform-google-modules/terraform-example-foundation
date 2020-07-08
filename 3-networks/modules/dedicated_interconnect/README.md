<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| default\_region1 | First subnet region. The dedicated Interconnect module only configures two regions. | string | n/a | yes |
| default\_region2 | Second subnet region. The dedicated Interconnect module only configures two regions. | string | n/a | yes |
| interconnect1\_region1 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| interconnect1\_region2 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| interconnect2\_region1 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| interconnect2\_region2 | URL of the underlying Interconnect object that this attachment's traffic will traverse through. | string | n/a | yes |
| interconnect\_location1\_region1 | Name of the interconnect location used in the creation of the Interconnect for the first location of region1 | string | n/a | yes |
| interconnect\_location1\_region2 | Name of the interconnect location used in the creation of the Interconnect for the first location of region2 | string | n/a | yes |
| interconnect\_location2\_region1 | Name of the interconnect location used in the creation of the Interconnect for the second location of region1 | string | n/a | yes |
| interconnect\_location2\_region2 | Name of the interconnect location used in the creation of the Interconnect for the second location of region2 | string | n/a | yes |
| peer\_asn | Peer BGP Autonomous System Number (ASN). | number | n/a | yes |
| peer\_ip\_address | IP address of the BGP interface outside Google Cloud Platform. Only IPv4 is supported. | string | n/a | yes |
| peer\_name | Name of this BGP peer. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression [a-z]([-a-z0-9]*[a-z0-9])? | string | n/a | yes |
| region1\_router1\_name | Name of the Router 1 for Region 1 where the attachment resides. | string | n/a | yes |
| region1\_router2\_name | Name of the Router 2 for Region 1 where the attachment resides. | string | n/a | yes |
| region2\_router1\_name | Name of the Router 1 for Region 2 where the attachment resides. | string | n/a | yes |
| region2\_router2\_name | Name of the Router 2 for Region 2 where the attachment resides | string | n/a | yes |
| vpc\_name | lable to identify the VPC associated with shared VPC that will use the Interconnect. | string | n/a | yes |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
