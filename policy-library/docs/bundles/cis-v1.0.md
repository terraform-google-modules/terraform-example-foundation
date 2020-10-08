# cis-v1.0

This bundle can be installed via kpt:

```
export BUNDLE=cis-v1.0
kpt pkg get https://github.com/forseti-security/policy-library.git ./policy-library
kpt fn source policy-library/samples/ | \
  kpt fn run --image gcr.io/config-validator/get-policy-bundle:latest -- bundle=$BUNDLE | \
  kpt fn sink policy-library/policies/constraints/
```

## Constraints

| Constraint                                                                                | Control | Description                                                                   |
| ----------------------------------------------------------------------------------------- | ------- | ----------------------------------------------------------------------------- |
| [disable_gke_dashboard](../../samples/gke_dashboard_disable.yaml)                         | 7.06    | Ensure Kubernetes web UI / Dashboard is disabled                              |
| [enable_auto_upgrade](../../samples/gke_node_pool_auto_upgrade.yaml)                      | 7.08    | Ensure Automatic node upgrades is enabled on Kubernetes Engine Clusters nodes |
| [enable_gke_stackdriver_logging](../../samples/gke_enable_stackdriver_logging.yaml)       | 7.01    | Ensure stackdriver logging is enabled on a GKE cluster                        |
| [enable_gke_stackdriver_monitoring](../../samples/gke_enable_stackdriver_monitoring.yaml) | 7.02    | Ensure stackdriver monitoring is enabled on a GKE cluster                     |

