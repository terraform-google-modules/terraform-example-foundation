# Hub & Spoke Transitivity module

This module implements transitivity for hub & spoke VPC architectures using appliance VMs behind an
Internal Load Balancer used as next-hop for routes.

## Usage

For example usage, please check the the [net-hubs-transitivity.tf](../../envs/shared/net-hubs-transitivity.tf) file.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| commands | Commands for the transitivity gateway to run on every boot. | `list(string)` | `[]` | no |
| firewall\_enable\_logging | Toggle firewall logging for VPC Firewalls. | `bool` | `true` | no |
| firewall\_policy | Network Firewall Policy Id to deploy transitivity firewall rules. | `string` | n/a | yes |
| gw\_subnets | Subnets in {REGION => SUBNET} format. | `map(string)` | n/a | yes |
| health\_check\_enable\_log | Toggle logging for health checks. | `bool` | `false` | no |
| project\_id | VPC Project ID | `string` | n/a | yes |
| regional\_aggregates | Aggregate ranges for each region in {REGION => [AGGREGATE\_CIDR,] } format. | `map(list(string))` | n/a | yes |
| regions | Regions to deploy the transitivity appliances | `set(string)` | `null` | no |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |

## Outputs

No outputs.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
