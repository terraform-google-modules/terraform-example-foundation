# 3-networks-hub-and-spoke/shared

The purpose of this step is to set up the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones) that will be used by all environments. This step will also create the Network Hubs that are part of the [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke) setup.

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
| base\_hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Base Hub | `bool` | `false` | no |
| bgp\_asn\_dns | BGP Autonomous System Number (ASN). | `number` | `64667` | no |
| custom\_restricted\_services | List of custom services to be protected by the VPC-SC perimeter. If empty, all supported services (https://cloud.google.com/vpc-service-controls/docs/supported-products) will be protected. | `list(string)` | `[]` | no |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | `bool` | `true` | no |
| domain | The DNS name of forwarding managed zone, for instance 'example.com'. Must end with a period. | `string` | n/a | yes |
| egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference), each list object has a `from` and `to` value that describes egress\_from and egress\_to.<br><br>Example: `[{ from={ identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| enable\_dedicated\_interconnect | Enable Dedicated Interconnect in the environment. | `bool` | `false` | no |
| enable\_hub\_and\_spoke\_transitivity | Enable transitivity via gateway VMs on Hub-and-Spoke architecture. | `bool` | `false` | no |
| enable\_partner\_interconnect | Enable Partner Interconnect in the environment. | `bool` | `false` | no |
| firewall\_policies\_enable\_logging | Toggle hierarchical firewall logging. | `bool` | `true` | no |
| ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference), each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| perimeter\_additional\_members | The list of additional members to be added to the perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`. | `list(string)` | n/a | yes |
| preactivate\_partner\_interconnect | Preactivate Partner Interconnect VLAN attachment in the environment. | `bool` | `false` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| restricted\_hub\_dns\_enable\_inbound\_forwarding | Toggle inbound query forwarding for Restricted Hub VPC DNS. | `bool` | `true` | no |
| restricted\_hub\_dns\_enable\_logging | Toggle DNS logging for Restricted Hub VPC DNS. | `bool` | `true` | no |
| restricted\_hub\_firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls in Restricted Hub VPC. | `bool` | `true` | no |
| restricted\_hub\_nat\_bgp\_asn | BGP ASN for first NAT cloud routes in Restricted Hub. | `number` | `64514` | no |
| restricted\_hub\_nat\_enabled | Toggle creation of NAT cloud router in Restricted Hub. | `bool` | `false` | no |
| restricted\_hub\_nat\_num\_addresses\_region1 | Number of external IPs to reserve for first Cloud NAT in Restricted Hub. | `number` | `2` | no |
| restricted\_hub\_nat\_num\_addresses\_region2 | Number of external IPs to reserve for second Cloud NAT in Restricted Hub. | `number` | `2` | no |
| restricted\_hub\_windows\_activation\_enabled | Enable Windows license activation for Windows workloads in Restricted Hub. | `bool` | `false` | no |
| subnetworks\_enable\_logging | Toggle subnetworks flow logging for VPC Subnetworks. | `bool` | `true` | no |
| target\_name\_server\_addresses | List of IPv4 address of target name servers for the forwarding zone configuration. See https://cloud.google.com/dns/docs/overview#dns-forwarding-zones for details on target name servers in the context of Cloud DNS forwarding zones. | `list(map(any))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns\_hub\_project\_id | The DNS hub project ID |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
