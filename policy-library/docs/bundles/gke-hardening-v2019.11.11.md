# gke-hardening-v2019.11.11

This bundle can be installed via kpt:

```
export BUNDLE=gke-hardening-v2019.11.11
kpt pkg get https://github.com/forseti-security/policy-library.git ./policy-library
kpt fn source policy-library/samples/ | \
  kpt fn run --image gcr.io/config-validator/get-policy-bundle:latest -- bundle=$BUNDLE | \
  kpt fn sink policy-library/policies/constraints/
```

## Constraints

| Constraint                                                                                         | Control                           | Description                                                                       |
| -------------------------------------------------------------------------------------------------- | --------------------------------- | --------------------------------------------------------------------------------- |
| [disable_gke_dashboard](../../samples/gke_dashboard_disable.yaml)                                  | DISABLED_GKE_DASHBOARD            | Ensure Kubernetes web UI / Dashboard is disabled                                  |
| [disable_gke_legacy_abac](../../samples/gke_legacy_abac.yaml)                                      | DISABLED_LEGACY_AUTHORIZATION     | Ensure Legacy Authorization is set to Disabled on Kubernetes Engine Clusters      |
| [enable_auto_upgrade](../../samples/gke_node_pool_auto_upgrade.yaml)                               | ENABLED_NODE_AUTO_UPGRADE         | Ensure Automatic node upgrades is enabled on Kubernetes Engine Clusters nodes     |
| [enable_gke_master_authorized_networks](../../samples/gke_master_authorized_networks_enabled.yaml) | ENABLED_MASTER_AUTHORIZED_NETWORK | Ensure Master authorized networks is set to Enabled on Kubernetes Engine Clusters |

