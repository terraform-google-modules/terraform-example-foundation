# 3-networks/dev

The purpose of this step is to setup private and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem dedicated interconnect, onprem VPN and baseline firewall rules for environment dev.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments/envs/dev executed successfully.
1. 3-networks/envs/shared executed successfully.
1. Obtain the value for the access_context_manager_policy_id variable. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`.

## Usage

### Run terraform locally
1. Change into 3-networks/envs/dev folder
1. Rename terraform.example.tfvars to terraform.tfvars and update the file with values from your environment and bootstrap.
1. Update backend.tf with your bucket from bootstrap.
1. Run `terraform init`
1. Run `terraform plan` and review output
1. Run `terraform apply`


### Using High Availability VPN
If you are not able to use dedicated interconnect you can also use an HA VPN to access onprem.

1. Rename `vpn.tf.example` to `vpn.tf` in the environment folder in `3-networks/envs/dev`
1. Create secret for VPN private preshared key `echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_PRIVATE_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-`
1. Create secret for VPN restricted preshared key `echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create <VPN_RESTRICTED_PSK_SECRET_NAME> --project <ENV_SECRETS_PROJECT> --replication-policy=automatic --data-file=-`
1. Update in the file `vpn.tf` the values for `environment`, `vpn_psk_secret_name`, `on_prem_router_ip_address1`, `on_prem_router_ip_address2` and `bgp_peer_asn`.
1. Verify other default values are valid for your environment.

__Note:__ You can get the environment secrets project executing `gcloud projects list --filter="labels.environment=dev labels.application_name=env-secrets"`

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| access\_context\_manager\_policy\_id | The id of the default Access Context Manager policy created in step `1-org`. Can be obtained by running `gcloud access-context-manager policies list --organization YOUR-ORGANIZATION_ID --format="value(name)"`. | number | n/a | yes |
| default\_region1 | First subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| default\_region2 | Second subnet region. The shared vpc modules only configures two regions. | string | n/a | yes |
| dns\_enable\_logging | Toggle DNS logging for VPC DNS. | bool | `"true"` | no |
| domain | The DNS name of peering managed zone, for instance 'example.com.' | string | n/a | yes |
| firewall\_enable\_logging | Toggle firewall logginglogging for VPC Firewalls. | bool | `"true"` | no |
| org\_id | Organization ID | string | n/a | yes |
| parent\_folder | Optional - if using a folder for testing. | string | `""` | no |
| subnetworks\_enable\_logging | Toggle subnetworks flow logging for VPC Subnetwoks. | bool | `"true"` | no |
| terraform\_service\_account | Service account email of the account to impersonate to run Terraform. | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_host\_project\_id | The private host project ID |
| private\_network\_name | The name of the VPC being created |
| private\_network\_self\_link | The URI of the VPC being created |
| private\_subnets\_ips | The IPs and CIDRs of the subnets being created |
| private\_subnets\_names | The names of the subnets being created |
| private\_subnets\_secondary\_ranges | The secondary ranges associated with these subnets |
| private\_subnets\_self\_links | The self-links of subnets being created |
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
