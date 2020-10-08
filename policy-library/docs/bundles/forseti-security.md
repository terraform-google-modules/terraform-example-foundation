# forseti-security

This bundle can be installed via kpt:

```
export BUNDLE=forseti-security
kpt pkg get https://github.com/forseti-security/policy-library.git ./policy-library
kpt fn source policy-library/samples/ | \
  kpt fn run --image gcr.io/config-validator/get-policy-bundle:latest -- bundle=$BUNDLE | \
  kpt fn sink policy-library/policies/constraints/
```

## Constraints

| Constraint                                                                                                                    | Control | Description                                                                                |
| ----------------------------------------------------------------------------------------------------------------------------- | ------- | ------------------------------------------------------------------------------------------ |
| [cmek_rotation_one_hundred_days](../../samples/cmek_rotation_100_days.yaml)                                                   | v2.26.0 | Checks that CMEK rotation policy is in place and is sufficiently short.                    |
| [denylist_public_users](../../samples/storage_denylist_public.yaml)                                                           | v2.26.0 | Prevent public users from having access to resources via IAM                               |
| [iam-restrict-service-account-key-age-one-hundred-days](../../samples/gcp_iam_restrict_service_account_key_age_100_days.yaml) | v2.26.0 | Checks if service account keys are older than 100 days.                                    |
| [only_my_domain](../../samples/iam_restrict_domain.yaml)                                                                      | v2.26.0 | Only allow members from my domain to be added to IAM roles                                 |
| [require_bq_table_iam](../../samples/bigquery_world_readable.yaml)                                                            | v2.26.0 | Checks if BigQuery datasets are publicly readable or allAuthenticatedUsers.                |
| [restrict-firewall-rule-world-open](../../samples/restrict_fw_rules_world_open.yaml)                                          | v2.26.0 | Checks for open firewall rules allowing ingress from the internet.                         |
| [restrict-firewall-rule-world-open-tcp-udp-all-ports](../../samples/restrict_fw_rules_world_open_tcp_udp_all_ports.yaml)      | v2.26.0 | Checks for open firewall rules allowing TCP/UDP from the internet.                         |
| [restrict-gmail-bigquery-dataset](../../samples/iam_restrict_gmail_bigquery_dataset.yaml)                                     | v2.26.0 | Enforce corporate domain by banning gmail.com addresses access to BigQuery datasets        |
| [restrict-googlegroups-bigquery-dataset](../../samples/iam_restrict_googlegroups_bigquery_dataset.yaml)                       | v2.26.0 | Enforce corporate domain by banning googlegroups.com addresses access to BigQuery datasets |
| [sql-world-readable](../../samples/sql_world_readable.yaml)                                                                   | v2.26.0 | Checks if Cloud SQL instances are world readable.                                          |

