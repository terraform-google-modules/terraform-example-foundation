# 3-networks-dual-svpc/development

The purpose of this step is to set up base and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem Dedicated Interconnect, onprem VPN and baseline firewall rules for environment development.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments/envs/development executed successfully.
1. 3-networks-dual-svpc/envs/shared executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| domain | The DNS name of peering managed zone, for instance 'example.com.'. Must end with a period. | `string` | n/a | yes |
| egress\_policies | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) to use in an enforced perimeter. Each list object has a `from` and `to` value that describes egress\_from and egress\_to.<br><br>Example: `[{ from={ identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| egress\_policies\_dry\_run | A list of all [egress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#egress-rules-reference) to use in a dry-run perimeter. Each list object has a `from` and `to` value that describes egress\_from and egress\_to.<br><br>Example: `[{ from={ identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| ingress\_policies | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference) to use in an enforced perimeter. Each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| ingress\_policies\_dry\_run | A list of all [ingress policies](https://cloud.google.com/vpc-service-controls/docs/ingress-egress-rules#ingress-rules-reference) to use in a dry-run perimeter. Each list object has a `from` and `to` value that describes ingress\_from and ingress\_to.<br><br>Example: `[{ from={ sources={ resources=[], access_levels=[] }, identities=[], identity_type="ID_TYPE" }, to={ resources=[], operations={ "SRV_NAME"={ OP_TYPE=[] }}}}]`<br><br>Valid Values:<br>`ID_TYPE` = `null` or `IDENTITY_TYPE_UNSPECIFIED` (only allow indentities from list); `ANY_IDENTITY`; `ANY_USER_ACCOUNT`; `ANY_SERVICE_ACCOUNT`<br>`SRV_NAME` = "`*`" (allow all services) or [Specific Services](https://cloud.google.com/vpc-service-controls/docs/supported-products#supported_products)<br>`OP_TYPE` = [methods](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) or [permissions](https://cloud.google.com/vpc-service-controls/docs/supported-method-restrictions) | <pre>list(object({<br>    from = any<br>    to   = any<br>  }))</pre> | `[]` | no |
| perimeter\_additional\_members | The list of additional members to be added to the enforced perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`. | `list(string)` | `[]` | no |
| perimeter\_additional\_members\_dry\_run | The list of additional members to be added to the dry-run perimeter access level members list. To be able to see the resources protected by the VPC Service Controls in the restricted perimeter, add your user in this list. Entries must be in the standard GCP form: `user:email@example.com` or `serviceAccount:my-service-account@example.com`. | `list(string)` | `[]` | no |
| remote\_state\_bucket | Backend bucket to load Terraform Remote State Data from previous steps. | `string` | n/a | yes |
| tfc\_org\_name | Name of the TFC organization | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| access\_context\_manager\_policy\_id | Access Context Manager Policy ID. |
| access\_level\_name | Access context manager access level name |
| access\_level\_name\_dry\_run | Access context manager access level name for the dry-run perimeter |
| base\_host\_project\_id | The base host project ID |
| base\_network\_name | The name of the VPC being created |
| base\_network\_self\_link | The URI of the VPC being created |
| base\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| base\_subnets\_names | The names of the subnets being created |
| base\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| base\_subnets\_self\_links | The self-links of subnets being created |
| enforce\_vpcsc | Enable the enforced mode for VPC Service Controls. It is not recommended to enable VPC-SC on the first run deploying your foundation. Review [best practices for enabling VPC Service Controls](https://cloud.google.com/vpc-service-controls/docs/enable), then only enforce the perimeter after you have analyzed the access patterns in your dry-run perimeter and created the necessary exceptions for your use cases. |
| restricted\_host\_project\_id | The restricted host project ID |
| restricted\_network\_name | The name of the VPC being created |
| restricted\_network\_self\_link | The URI of the VPC being created |
| restricted\_service\_perimeter\_name | Access context manager service perimeter name |
| restricted\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| restricted\_subnets\_names | The names of the subnets being created |
| restricted\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| restricted\_subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
