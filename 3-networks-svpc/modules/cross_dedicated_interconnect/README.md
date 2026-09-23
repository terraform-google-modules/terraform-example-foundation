# Dedicated Interconnect module

This module implements the recommendation proposed in [Cross-Cloud Interconnect overview - Production critical](https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/cci-overview#high-availability).

## Prerequisites

1. Provisioning of four [Cross-Cloud Dedicated Interconnect connections](https://docs.cloud.google.com/network-connectivity/docs/interconnect/concepts/cci-overview) in the `prj-interconnect` project created in step `1-org` under folder `fldr-common`.

## Usage

1. Rename `routers.tf.example` to `routers..tf` in the base-env folder in `3-networks-svpc/modules/base_env`
1. Rename `cross_interconnect.tf.example` to `cross_interconnect.tf` in the shared envs folder in `3-networks-svpc/modules/base_env`
1. Update the file `cross_interconnect.tf` with values that are valid for your environment for the interconnects, locations, candidate subnetworks, vlan_tag8021q and peer info.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cross\_cloud\_config | Cross-Cloud Interconnect configuration containing remote provider settings and attachment definitions.<br><br>  Top-level attributes:<br>    - remote\_cloud\_provider: Target cloud provider. Must be one of: 'aws', 'azure', or 'oci'.<br>    - peer\_asn:              (Optional) Default BGP Autonomous System Number (ASN) of the remote cloud peer router.<br>    - peer\_name:             (Optional) Default name for the remote BGP peer configuration.<br>    - attachments:           Map of interconnect attachment configuration objects keyed by a unique identifier.<br><br>  Attachment attributes (map values):<br>    - region:            Google Cloud region where the attachment and Cloud Router reside (e.g., 'us-central1').<br>    - router:            Name or resource reference of the Google Cloud Router to attach to.<br>    - cross\_dc:          Identifier for the remote cloud data center or facility location (e.g., 'aws-dc1').<br>    - location:          Google Cloud Interconnect edge location code (e.g., 'iad-zone1-1').<br>    - cr\_suffix:         Suffix identifier used when constructing Cloud Router interface and subinterface names (e.g., 'cr1').<br>    - interconnect:      Resource URL or ID of the underlying physical Dedicated Interconnect connection.<br>    - candidate\_subnets: (Optional) List of link-local IPv4 CIDR ranges (e.g., /29 or /30) for candidate BGP IP allocation.<br>    - vlan\_tag8021q:     (Optional) Explicit 802.1Q VLAN encapsulation tag (required to be >= 100 for OCI).<br>    - peer\_name:         (Optional) Override for the remote BGP peer name on this specific attachment.<br>    - peer\_asn:          (Optional) Override for the remote BGP peer ASN on this specific attachment.<br>    - md5\_key:           (Optional) BGP MD5 authentication secret key (required for AWS Cross-Cloud Interconnect). | <pre>object({<br>    remote_cloud_provider = string<br>    peer_asn              = optional(number)<br>    peer_name             = optional(string)<br>    attachments = map(object({<br>      region            = string<br>      router            = string<br>      cross_dc          = string<br>      location          = string<br>      cr_suffix         = string<br>      interconnect      = string<br>      candidate_subnets = optional(list(string))<br>      vlan_tag8021q     = optional(number)<br>      peer_name         = optional(string)<br>      peer_asn          = optional(number)<br>      md5_key           = optional(string)<br>    }))<br>  })</pre> | n/a | yes |
| interconnect\_project\_id | Interconnect project ID. | `string` | n/a | yes |
| ncc\_hub\_group | Network Connectivity Center Group to attach the spoke to | `string` | n/a | yes |
| ncc\_hub\_uri | The full URI (ID) of the existing Network Connectivity Center Hub where the spokes will be attached. | `string` | n/a | yes |
| region1 | First subnet region. The Dedicated Interconnect module only configures two regions. | `string` | n/a | yes |
| region2 | Second subnet region. The Dedicated Interconnect module only configures two regions. | `string` | n/a | yes |
| site\_to\_site\_data\_transfer | Set to true to allow Google Cloud routing to act as a transit network between on-premises sites. | `bool` | `false` | no |
| vpc\_name | Label to identify the VPC associated with shared VPC that will use the Interconnect. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| customer\_router\_ip\_addresses | Map of IPv4 addresses + prefix lengths to configure on customer router subinterfaces. |
| interconnect\_attachments | Map of all interconnect attachment objects keyed by attachment name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
