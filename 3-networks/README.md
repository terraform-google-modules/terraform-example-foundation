# 3-networks

The purpose of this step is to:

- Setup the global [DNS Hub](https://cloud.google.com/blog/products/networking/cloud-forwarding-peering-and-zones).
- Setup private and restricted shared VPCs with default DNS, NAT (optional), Private Service networking, VPC service controls, onprem dedicated interconnect and baseline firewall rules for each environment.

## Prerequisites

1. 0-bootstrap executed successfully.
1. 1-org executed successfully.
1. 2-environments/envs/[dev|nonprod|prod] executed successfully.

## Usage

Follow the instructions in the README.md files of each individual 3-networks/envs/ folder.

**3-networks/envs/shared** must be executed successfully before environments `dev`, `nonprod` and `prod` are executed.
