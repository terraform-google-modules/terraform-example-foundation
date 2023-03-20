# 3-networks-dual-svpc/shared

The purpose of this step is to set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones) that will be used by all environments.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | `number` | `64667` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period. | `string` | n/a | yes |
| enable\_partner\_interconnect | Enable Partner Interconnect in the environment. | `bool` | `false` | no |
| firewall\_policies\_enable\_logging | Toggle hierarchical firewall logging. | `bool` | `true` | no |
| preactivate\_partner\_interconnect | Preactivate Partner Interconnect VLAN attachment in the environment. | `bool` | `false` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| subnetworks\_enable\_logging | Toggle subnetworks flow logging for VPC Subnetworks. | `bool` | `true` | no |
| target\_name\_server\_addresses | List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones. | `list(map(any))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns\_hub\_project\_id | The DNS hub project ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
