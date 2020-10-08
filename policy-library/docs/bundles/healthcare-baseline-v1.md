# healthcare-baseline-v1

This bundle can be installed via kpt:

```
export BUNDLE=healthcare-baseline-v1
kpt pkg get https://github.com/forseti-security/policy-library.git ./policy-library
kpt fn source policy-library/samples/ | \
  kpt fn run --image gcr.io/config-validator/get-policy-bundle:latest -- bundle=$BUNDLE | \
  kpt fn sink policy-library/policies/constraints/
```

## Constraints

| Constraint                                                                                           | Control  | Description                                                                    |
| ---------------------------------------------------------------------------------------------------- | -------- | ------------------------------------------------------------------------------ |
| [allow_appengine_applications_in_australia_and_south_america](../../samples/appengine_location.yaml) | security | Restrict locations (regions) where App Engine applications are deployed.       |
| [allow_basic_set_of_apis](../../samples/serviceusage_allow_basic_apis.yaml)                          | security | Only a basic set of APIS                                                       |
| [allow_dataproc_clusters_in_asia](../../samples/dataproc_location.yaml)                              | security | Checks that Dataproc clusters are in correct regions.                          |
| [allow_some_sql_location](../../samples/sql_location.yaml)                                           | security | Checks Cloud SQL instance locations against allowed or disallowed locations.   |
| [allow_some_storage_location](../../samples/storage_location.yaml)                                   | security | Checks Cloud Storage bucket locations against allowed or disallowed locations. |
| [allow_spanner_clusters_in_asia_and_europe](../../samples/spanner_location.yaml)                     | security | Checks Cloud Spanner locations.                                                |
| [audit_log_all](../../samples/iam_audit_log_all.yaml)                                                | security | Checks that all services have all types of audit logs enabled.                 |
| [bq_dataset_allowed_locations](../../samples/bq_dataset_location.yaml)                               | security | Checks in which locations BigQuery datasets exist.                             |
| [deny_allusers](../../samples/iam_deny_public.yaml)                                                  | security | Prevent public users from having access to resources via IAM                   |
| [denylist_public_users](../../samples/storage_denylist_public.yaml)                                  | security | Prevent public users from having access to resources via IAM                   |
| [enable-network-firewall-logs](../../samples/network_enable_firewall_logs.yaml)                      | security | Ensure Firewall logs is enabled for every firewall in VPC Network              |
| [enable_gke_stackdriver_logging](../../samples/gke_enable_stackdriver_logging.yaml)                  | security | Ensure stackdriver logging is enabled on a GKE cluster                         |
| [enable_network_flow_logs](../../samples/network_enable_flow_logs.yaml)                              | security | Ensure VPC Flow logs is enabled for every subnet in VPC Network                |
| [gke-cluster-allowed-locations](../../samples/gke_cluster_location.yaml)                             | security | Checks which zones are allowed/disallowed for GKE clusters.                    |
| [only_my_domain](../../samples/iam_restrict_domain.yaml)                                             | security | Only allow members from my domain to be added to IAM roles                     |
| [prevent-public-ip-cloudsql](../../samples/sql_public_ip.yaml)                                       | security | Prevents a public IP from being assigned to a Cloud SQL instance.              |
| [require_bq_table_iam](../../samples/bigquery_world_readable.yaml)                                   | security | Checks if BigQuery datasets are publicly readable or allAuthenticatedUsers.    |
| [require_bucket_policy_only](../../samples/storage_bucket_policy_only.yaml)                          | security | Checks if Cloud Storage buckets have Bucket Only Policy turned on.             |
| [sql-world-readable](../../samples/sql_world_readable.yaml)                                          | security | Checks if Cloud SQL instances are world readable.                              |

