# 3-networks/shared

The purpose of this step is to setup the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones) that will be used by all environments.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | number | `"64667"` | no |
| default\_region1 | First subnet region for DNS Hub network. | string | n/a | yes |
| default\_region2 | Second subnet region for DNS Hub network. | string | n/a | yes |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | bool | `"true"` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com' | string | n/a | yes |
| org\_id | Organization ID | string | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | string | `""` | no |
| subnetworks\_enable\_logging | Toggle subnetworks flow logging for VPC Subnetwoks. | bool | `"true"` | no |
| target\_name\_server\_addresses | List of target name servers for forwarding zone. | list(string) | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns\_hub\_project\_id | The DNS hub project ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
