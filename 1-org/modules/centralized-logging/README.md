# Centralized Logging Module

This module handles logging configuration enabling destination to: buckets, Big Query or Pub/Sub.

## Usage

Before using this module, one should get familiar with the `google_dataflow_flex_template_job`’s [Note on "destroy"/"apply"](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataflow_flex_template_job#note-on-destroy--apply) as the behavior is atypical when compared to other resources.

## Requirements

These sections describe requirements for running this module.

### Software

Install the following dependencies:

- [Google Cloud SDK](https://cloud.google.com/sdk/install) version 357.0.0 or later.
- [Terraform](https://www.terraform.io/downloads.html) version 0.13.7 or later.

### Deployer entity

To provision the resources of this module, create a service account
with the following IAM roles:

- Dataflow Developer:`roles/dataflow.developer`.

### APIs

The following APIs must be enabled in the project where the service account was created:

- BigQuery API: `bigquery.googleapis.com`.
- Cloud Key Management Service (KMS) API: `cloudkms.googleapis.com`.
- Google Cloud Storage JSON API:`storage-api.googleapis.com`.
- Compute Engine API: `compute.googleapis.com`.
- Dataflow API: `dataflow.googleapis.com`.

Any others APIs you pipeline may need.

### Assumption

One assumption is that, before using this module, you already have a working Dataflow flex job template(s) in a GCS location.
If you are not using public IPs, you need to [Configure Private Google Access](https://cloud.google.com/vpc/docs/configure-private-google-access)
on the VPC used by Dataflow.

This is a simple usage:

```hcl
module "dataflow-flex-job" {
  source  = "terraform-google-modules/secured-data-warehouse/google//modules/dataflow-flex-job"
  version = "~> 0.1"

  project_id              = "<project_id>"
  region                  = "us-east4"
  name                    = "dataflow-flex-job-00001"
  container_spec_gcs_path = "gs://<path-to-template>"
  staging_location        = "gs://<gcs_path_staging_data_bucket>"
  temp_location           = "gs://<gcs_path_temp_data_bucket>"
  subnetwork_self_link    = "<subnetwork-self-link>"
  kms_key_name            = "<fully-qualified-kms-key-id>"
  service_account_email   = "<dataflow-controller-service-account-email>"

  parameters = {
    firstParameter  = "ONE",
    secondParameter = "TWO
  }
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| audit\_logs\_table\_delete\_contents\_on\_destroy | (Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present. | `bool` | `false` | no |
| audit\_logs\_table\_expiration\_days | Period before tables expire for all audit logs in milliseconds. Default is 30 days. | `number` | `30` | no |
| bigquery\_options | (Optional) Options that affect sinks exporting data to BigQuery. use\_partitioned\_tables - (Required) Whether to use BigQuery's partition tables. | <pre>object({<br>    use_partitioned_tables = bool<br>  })</pre> | `null` | no |
| data\_access\_logs\_enabled | Enable Data Access logs of types DATA\_READ, DATA\_WRITE for all GCP services in the projects specified in the provided `projects_ids` map. Enabling Data Access logs might result in your organization being charged for the additional logs usage. See https://cloud.google.com/logging/docs/audit#data-access The ADMIN\_READ logs are enabled by default. | `bool` | `false` | no |
| delete\_contents\_on\_destroy | (Optional) If set to true, disable the prevent destroy protection in the KMS keys. | `bool` | `false` | no |
| exclusions | (Optional) A list of sink exclusion filters. | <pre>list(object({<br>    name        = string,<br>    description = string,<br>    filter      = string,<br>    disabled    = bool<br>  }))</pre> | `[]` | no |
| key\_rotation\_period\_seconds | Rotation period for keys. The default value is 30 days. | `string` | `"2592000s"` | no |
| kms\_key\_protection\_level | The protection level to use when creating a key. Possible values: ["SOFTWARE", "HSM"] | `string` | `"HSM"` | no |
| kms\_project\_id | The ID of the project in which the Cloud KMS keys will be created. | `string` | n/a | yes |
| labels | (Optional) Labels attached to Data Warehouse resources. | `map(string)` | `{}` | no |
| log\_export\_storage\_force\_destroy | (Optional) If set to true, delete all contents when destroying the resource; otherwise, destroying the resource will fail if contents are present. | `bool` | `false` | no |
| log\_export\_storage\_retention\_policy | Configuration of the bucket's data retention policy for how long objects in the bucket should be retained. | <pre>object({<br>    is_locked             = bool<br>    retention_period_days = number<br>  })</pre> | `null` | no |
| log\_export\_storage\_versioning | (Optional) Toggles bucket versioning, ability to retain a non-current object version when the live object version gets replaced or deleted. | `bool` | `false` | no |
| logging\_create\_target | (Optional) If set to true, the module will create a container (bigquery, storage, or pubsub); otherwise, the module will consider that the container already exists. | `bool` | `false` | no |
| logging\_destination\_project\_id | The ID of the project that will have the resources where the logs will be created. | `string` | n/a | yes |
| logging\_location | A valid location for the bucket and KMS key that will be deployed. | `string` | `"us-east4"` | no |
| logging\_target\_name | The name of the logging container (bigquery, storage, or pubsub) that will store the logs. | `string` | `""` | no |
| logging\_target\_type | Resource type of the resource that will store the logs. Must be: bigquery, storage, or pubsub | `string` | n/a | yes |
| resource\_type | Resource type of the resource that will export logs to destination. Must be: project, organization or folder | `string` | n/a | yes |
| resources | Export logs from the specified resources. | `map(string)` | n/a | yes |
| sink\_filter | The filter to apply when exporting logs. Only log entries that match the filter are exported. Default is '' which exports all logs. | `string` | `"    logName: /logs/cloudaudit.googleapis.com%2Factivity OR\n    logName: /logs/cloudaudit.googleapis.com%2Fsystem_event OR\n    logName: /logs/cloudaudit.googleapis.com%2Fdata_access OR\n    logName: /logs/compute.googleapis.com%2Fvpc_flows OR\n    logName: /logs/compute.googleapis.com%2Ffirewall OR\n    logName: /logs/cloudaudit.googleapis.com%2Faccess_transparency\n"` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
