# Cloud Build access to on-prem

The infrastructure create for the Cloud Build deploy allows access to on-prem resources by setting up [Private Pools](https://cloud.google.com/build/docs/private-pools/private-pools-overview), [VPC Network Peering](https://cloud.google.com/vpc/docs/vpc-peering) between Google's [service producer network](https://cloud.google.com/build/docs/private-pools/set-up-private-pool-to-use-in-vpc-network#setup-private-connection) and a VPC network in the CI/CD project, and on-prem connection with one of three options:

- [High Availability VPN](https://cloud.google.com/network-connectivity/docs/vpn/concepts/topologies#overview)
- [Dedicated Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/dedicated-creating-9999-availability)
- [Partner Interconnect](https://cloud.google.com/network-connectivity/docs/interconnect/tutorials/partner-creating-9999-availability)

In all the three connection options it is necessary to configure a router using the [Custom route advertisement mode](https://cloud.google.com/network-connectivity/docs/router/concepts/overview#route-advertisement-custom) so that the Google service network private pool instance that executes the Cloud build jobs can reach instances in the on-prem network.

HA VPN, Dedicated Interconnect and Partner Interconnect configuration can be setup in one of the two network modes: [Dual Shared VPC](https://cloud.google.com/architecture/security-foundations/networking#vpcsharedvpc-id7-1-shared-vpc-) or [Hub and Spoke](https://cloud.google.com/architecture/security-foundations/networking#hub-and-spoke).

For Cloud Build jobs to access on-prem infrastructure, [Import and export custom routes](https://cloud.google.com/vpc/docs/vpc-peering#importing-exporting-routes) are also configured in the peering setup.

0-bootstrap step also has an optional High Availability VPN configuration that can be used to on-prem connection.
To enable this configuration do the following steps:

1. Create a secret for the VPN private pre-shared key and grant required roles to the identity used for the deploy, your user email or the Bootstrap terraform service account.


   ```bash
   export project_id=<ENV_SECRETS_PROJECT>
   export secret_name=<VPN_PSK_SECRET_NAME>
   export member="serviceAccount:<BOOTSTRAP_TERRAFORM_SERVICE_ACCOUNT>|user:<YOUR_EMAIL>"

   echo '<YOUR-PRESHARED-KEY-SECRET>' | gcloud secrets create "${secret_name}" --project "${project_id}" --replication-policy=automatic --data-file=-

   gcloud secrets add-iam-policy-binding "${secret_name}"  --member="${member}" --role='roles/secretmanager.viewer' --project "${project_id}"

   gcloud secrets add-iam-policy-binding "${secret_name}"  --member="${member}"  --role='roles/secretmanager.secretAccessor' --project "${project_id}"
   ```

1. In the file `0-bootstrap/cb.tf`, in the module `tf_private_pool`, update variable `vpn_configuration.enable_vpn` to `true` and provide the required values that are valid for your environment. See the `cb-private-pool` module [README](./modules/cb-private-pool/README.md) file for additional information on the required values.
