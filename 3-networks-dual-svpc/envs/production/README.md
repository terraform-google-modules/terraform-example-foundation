# 3-networks-dual-svpc/production

The purpose of this step is to set up base and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem Dedicated Interconnect, onprem VPN and baseline firewall rules for environment production.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments/envs/production executed successfully.
1. 3-networks-dual-svpc/envs/shared executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR_ORGANIZATION_ID --format="value(name)"`. | `number` | n/a | yes |
| domain | The DNS name of peering managed zone, for instance 'example.com.'. Must end with a period. | `string` | n/a | yes |
| folder\_prefix | Name prefix to use for folders created. Should be the same in all steps. | `string` | `"fldr"` | no |
| org\_id | Organization ID | `string` | n/a | yes |
| parent\_folder | Optional - for an organization with existing projects or for development/validation. It will place all the example foundation resources under the provided folder instead of the root organization. The value is the numeric folder ID. The folder must already exist. Must be the same value used in previous step. | `string` | `""` | no |
| terraform\_service\_account | Service account email of the account to be added to the VPC-SC perimeter. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| base\_host\_project\_id | The base host project ID |
| base\_network\_name | The name of the VPC being created |
| base\_network\_self\_link | The URI of the VPC being created |
| base\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| base\_subnets\_names | The names of the subnets being created |
| base\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| base\_subnets\_self\_links | The self-links of subnets being created |
| restricted\_access\_level\_name | Access context manager access level name |
| restricted\_host\_project\_id | The restricted host project ID |
| restricted\_network\_name | The name of the VPC being created |
| restricted\_network\_self\_link | The URI of the VPC being created |
| restricted\_service\_perimeter\_name | Access context manager service perimeter name |
| restricted\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| restricted\_subnets\_names | The names of the subnets being created |
| restricted\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| restricted\_subnets\_self\_links | The self-links of subnets being created |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
