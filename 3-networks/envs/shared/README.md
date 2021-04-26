# 3-networks/shared

The purpose of this step is to set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones) that will be used by all environments.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| base\_hub\_dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for Base Hub VPC DNS. | `bool` | `true` | no |
| base\_hub\_dns\_enable\_logging | Toggle DNS logging for Base Hub VPC DNS. | `bool` | `true` | no |
| base\_hub\_firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls in Base Hub VPC. | `bool` | `true` | no |
| base\_hub\_nat\_bgp\_asn | BGP ASN for first NAT cloud routes in Base Hub. | `number` | `64514` | no |
| base\_hub\_nat\_enabled | Toggle creation of NAT cloud router in Base Hub. | `bool` | `false` | no |
| base\_hub\_nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT in Base Hub. | `number` | `2` | no |
| base\_hub\_nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT in Base Hub. | `number` | `2` | no |
| base\_hub\_optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules: IAP SSH, IAP RDP and Internal & Global load balancing health check and load balancing IP ranges in Base Hub VPC. | `bool` | `false` | no |
| base\_hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Base Hub | `bool` | `false` | no |
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | `number` | `64667` | no |
| default\_region1 | First subnet region for DNS Hub network. | `string` | n/a | yes |
| default\_region2 | Second subnet region for DNS Hub network. | `string` | n/a | yes |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period. | `string` | n/a | yes |
| enable\_hub\_and\_spoke | Enable Hub-and-Spoke architecture. | `bool` | `false` | no |
| enable\_hub\_and\_spoke\_transitivity | Enable transitivity via gateway VMs on Hub-and-Spoke architecture. | `bool` | `false` | no |
| enable\_partner\_interconnect | Enable Partner Interconnect in the environment. | `bool` | `false` | no |
| firewall\_policies\_enable\_logging | Toggle hierarchical firewall logging. | `bool` | `true` | no |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| org\_id | Organization ID | `string` | n/a | yes |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| preactivate\_partner\_interconnect | Preactivate Partner Interconnect VLAN attachment in the environment. | `bool` | `false` | no |
| restricted\_hub\_dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for Restricted Hub VPC DNS. | `bool` | `true` | no |
| restricted\_hub\_dns\_enable\_logging | Toggle DNS logging for Restricted Hub VPC DNS. | `bool` | `true` | no |
| restricted\_hub\_firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls in Restricted Hub VPC. | `bool` | `true` | no |
| restricted\_hub\_nat\_bgp\_asn | BGP ASN for first NAT cloud routes in Restricted Hub. | `number` | `64514` | no |
| restricted\_hub\_nat\_enabled | Toggle creation of NAT cloud router in Restricted Hub. | `bool` | `false` | no |
| restricted\_hub\_nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT in Restricted Hub. | `number` | `2` | no |
| restricted\_hub\_nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT in Restricted Hub. | `number` | `2` | no |
| restricted\_hub\_optional\_fw\_rules\_enabled | Toggle creation of optional firewall rules: IAP SSH, IAP RDP and Internal & Global load balancing health check and load balancing IP ranges in Restricted Hub VPC. | `bool` | `false` | no |
| restricted\_hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Restricted Hub. | `bool` | `false` | no |
| subnetworks\_enable\_logging | Toggle subnetworks flow logging for VPC Subnetworks. | `bool` | `true` | no |
| target\_name\_server\_addresses | List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones. | `list(string)` | n/a | yes |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns\_hub\_project\_id | The DNS hub project ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
