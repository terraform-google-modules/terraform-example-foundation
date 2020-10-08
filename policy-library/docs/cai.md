# Cloud Asset Inventory

Config Validator constraints are based on [Cloud Asset Inventory](https://cloud.google.com/resource-manager/docs/cloud-asset-inventory/overview) resources.
Therefore, it is helpful to have CAI reference data when developing new constraint templates. This page contains some simple documentation for exporting CAI data and working with it locally.

## Exporting Data
These steps *must* be conducted from a VM or using a Service Account on a project. See [this documentation](https://cloud.google.com/resource-manager/docs/cloud-asset-inventory/quickstart-cloud-asset-inventory#exporting_an_asset_snapshot) for more details.

1. Export an index

    ```
    MY_BUCKET=inventory-bucket
    TOKEN=$(gcloud auth print-access-token)
    ORG_ID=$(gcloud organizations list --format='value(ID)')

    curl -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
        -d '{"contentType":"RESOURCE", "outputConfig":{"gcsDestination":{"uri":"gs://$MY_BUCKET/resource_inventory.json"}}}' \
            https://cloudasset.googleapis.com/v1/organizations/$ORG_ID\:exportAssets
    ```

2. Export policies.

    ```
    curl -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
        -d '{"contentType":"IAM_POLICY", "outputConfig":{"gcsDestination":{"uri":"gs://$MY_BUCKET/iam_inventory.json"}}}' \
            https://cloudasset.googleapis.com/v1/organizations/$ORG_ID\:exportAssets
    ```

3. Check operation status

    ```
    curl -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
            https://cloudasset.googleapis.com/v1/organizations/$ORG_ID/operations/ExportAssets/14988324955088615864
    ```

## Finding Resources

These commands can be used to parse specific resources from the CAI dump.

- All data

    cat inventory.json | jq -n '[inputs | select(length>0)][0:10]'

    cat inventory.json | jq -n '[inputs | select(length>0)][0:] | group_by(.asset_type) | .[][0]'

- get asset types

    cat inventory.json | jq -n '[inputs | select(length>0)][0:] | group_by(.asset_type) | .[][0] | .asset_type'

- compute instance

    cat inventory.json | jq -n '[inputs | select(length>0) | select(.asset_type=="google.compute.Instance")][0:10]'

- buckets

    cat inventory.json | jq -n '[inputs | select(length>0) | select(.asset_type=="google.cloud.storage.Bucket")][0:10]'

- projects

    cat inventory.json | jq -n '[inputs | select(length>0) | select(.asset_type=="google.cloud.resourcemanager.Project")][0:10]'

- get project IAM

    cat iam_inventory.json | jq -n '[inputs | select(length>0) | select(.asset_type=="google.cloud.resourcemanager.Project")][0:10]'
