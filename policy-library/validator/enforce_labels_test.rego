#
# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

package templates.gcp.GCPEnforceLabelConstraintV1

import data.validator.gcp.lib as lib
import data.validator.test_utils as test_utils

# Importing the test data

import data.test.fixtures.enforce_labels.assets.bigtable as fixture_bigtable
import data.test.fixtures.enforce_labels.assets.bq as fixture_bq
import data.test.fixtures.enforce_labels.assets.buckets as fixture_buckets
import data.test.fixtures.enforce_labels.assets.cloudsql as fixture_cloudsql
import data.test.fixtures.enforce_labels.assets.compute.disks as fixture_compute_disks
import data.test.fixtures.enforce_labels.assets.compute.images as fixture_compute_images
import data.test.fixtures.enforce_labels.assets.compute.instances as fixture_compute_instances
import data.test.fixtures.enforce_labels.assets.compute.snapshots as fixture_compute_snapshots
import data.test.fixtures.enforce_labels.assets.dataproc.clusters as fixture_dataproc_clusters
import data.test.fixtures.enforce_labels.assets.dataproc.jobs as fixture_dataproc_jobs
import data.test.fixtures.enforce_labels.assets.gke as fixture_gke
import data.test.fixtures.enforce_labels.assets.projects as fixture_projects
import data.test.fixtures.enforce_labels.assets.spanner as fixture_spanner

# Importing the test constraint
import data.test.fixtures.enforce_labels.constraints as fixture_constraints

template_name := "GCPEnforceLabelConstraintV1"

##### Testing for projects

# Confirm six violations were found for all projects
# 4 projects have violations - 2 of which have 2 violations (one has 2 labels missing,
# the other has 2 labels with invalid values)
# confirm which 4 projects are in violation
test_enforce_label_projects_violations {
	expected_resource_names := {
		"//cloudresourcemanager.googleapis.com/projects/169463810970",
		"//cloudresourcemanager.googleapis.com/projects/357960133769",
		"//cloudresourcemanager.googleapis.com/projects/357960133899",
		"//cloudresourcemanager.googleapis.com/projects/357960133233",
	}

	test_utils.check_test_violations_count(fixture_projects, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_projects, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_projects, [fixture_constraints], template_name)
}

##### Testing for buckets

# Confirm exactly 6 bucket violations were found
# 4 buckets have violations - 2 of which have 2 violations (one has 2 labels missing,
# the other has 2 labels with invalid values)
# confirm which 4 buckets are in violation
test_enforce_label_bucket_violations {
	expected_resource_names := {
		"//storage.googleapis.com/bucket-with-no-labels",
		"//storage.googleapis.com/bucket-with-label2-missing",
		"//storage.googleapis.com/bucket-with-label1-missing",
		"//storage.googleapis.com/bucket-with-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_buckets, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_buckets, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_buckets, [fixture_constraints], template_name)
}

##### Testing for GCE resources

#### Testing for GCE instances

# Confirm exactly 6 instance violations were found
# 4 instances have violations - 2 of which have 2 violations (one has 2 labels missing, the other has 2 labels with invalid values)
# confirm which 4 instances are in violation
test_enforce_label_compute_instance_violations {
	expected_resource_names := {
		"//compute.googleapis.com/projects/vpc-sc-pub-sub-billing-alerts/zones/us-central1-b/instances/invalid-instance-missing-labels-8hz5",
		"//compute.googleapis.com/projects/vpc-sc-pub-sub-billing-alerts/zones/us-central1-b/instances/invalid-instance-missing-label1-8hz5",
		"//compute.googleapis.com/projects/vpc-sc-pub-sub-billing-alerts/zones/us-central1-b/instances/invalid-instance-missing-label2-8hz5",
		"//compute.googleapis.com/projects/vpc-sc-pub-sub-billing-alerts/zones/us-central1-b/instances/invalid-instance-with-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_compute_instances, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_compute_instances, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_compute_instances, [fixture_constraints], template_name)
}

#### Testing for GCE Images
# Confirm exactly 4 images violations were found
# 4 images have violations - 2 of which have 2 violations (one has 2 labels missing,
# the other has 2 labels with invalid values)
# confirm which 4 images are in violation
test_enforce_label_compute_image_violations {
	expected_resource_names := {
		"//compute.googleapis.com/projects/my-own-project/global/images/test-invalid-image-missing-labels",
		"//compute.googleapis.com/projects/my-own-project/global/images/test-invalid-image-missing-label2",
		"//compute.googleapis.com/projects/my-own-project/global/images/test-invalid-image-missing-label1",
		"//compute.googleapis.com/projects/my-own-project/global/images/test-invalid-image-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_compute_images, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_compute_images, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_compute_images, [fixture_constraints], template_name)
}

#### Testing for GCE Disks
# Confirm exactly 6 disk violations were found
# 4 disks have violations - 2 of which have 2 violations (one has 2 labels missing,
# the other has 2 labels with invalid values)
# confirm which 4 disks are in violation
test_enforce_label_compute_disk_violations {
	expected_resource_names := {
		"//compute.googleapis.com/projects/my-test-project/zones/us-east1-b/disks/instance-1-invalid-disk-missing-labels",
		"//compute.googleapis.com/projects/my-test-project/zones/us-east1-b/disks/instance-1-invalid-disk-missing-label1",
		"//compute.googleapis.com/projects/my-test-project/zones/us-east1-b/disks/instance-1-invalid-disk-missing-label2",
		"//compute.googleapis.com/projects/my-test-project/zones/us-east1-b/disks/instance-1-invalid-disk-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_compute_disks, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_compute_disks, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_compute_disks, [fixture_constraints], template_name)
}

#### Testing for GCE Snapshots
# Confirm exactly 6 snapshot violations were found
# 4 snapshots have violations - 2 of which have 2 violations (one has 2 labels missing,
# the other has 2 labels with invalid values)
# confirm which 4 snapshots are in violation
test_enforce_label_compute_snapshot_violations {
	expected_resource_names := {
		"//compute.googleapis.com/projects/my-test-project/global/snapshots/snapshot-1-invalid-missing-labels",
		"//compute.googleapis.com/projects/my-test-project/global/snapshots/snapshot-1-invalid-missing-label1",
		"//compute.googleapis.com/projects/my-test-project/global/snapshots/snapshot-1-invalid-missing-label2",
		"//compute.googleapis.com/projects/my-test-project/global/snapshots/snapshot-1-invalid-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_compute_snapshots, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_compute_snapshots, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_compute_snapshots, [fixture_constraints], template_name)
}

#### Testing for BigTable Instances
# Confirm exactly 6 bigtable violations were found
# 4 bigtable instances have violations - 2 of which have 2 violations (one has 2 labels missing, the other has 2 labels with invalid values)
# confirm which 4 bigtable instances are in violation
test_enforce_label_bigtable_violations {
	expected_resource_names := {
		"//bigtable.googleapis.com/projects/my-test-project/instances/test-bigtable-invalid-missing-labels",
		"//bigtable.googleapis.com/projects/my-test-project/instances/test-bigtable-invalid-missing-label1",
		"//bigtable.googleapis.com/projects/my-test-project/instances/test-bigtable-invalid-missing-label2",
		"//bigtable.googleapis.com/projects/my-test-project/instances/test-bigtable-invalid-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_bigtable, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_bigtable, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_bigtable, [fixture_constraints], template_name)
}

#### Testing for CloudSQL Instances
# Confirm exactly 6 cloudsql violations were found
# 4 cloudsql instances have violations - 2 of which have 2 violations (one has 2 labels missing, the other has 2 labels with invalid values)
# confirm which 4 cloudsql instances are in violation
test_enforce_label_cloudsql_violations {
	expected_resource_names := {
		"//cloudsql.googleapis.com/projects/my-test-project/instances/cloudsql-instance-1-invalid-missing-labels",
		"//cloudsql.googleapis.com/projects/my-test-project/instances/cloudsql-instance-1-invalid-missing-label1",
		"//cloudsql.googleapis.com/projects/my-test-project/instances/cloudsql-instance-1-invalid-missing-label2",
		"//cloudsql.googleapis.com/projects/my-test-project/instances/cloudsql-instance-1-invalid-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_cloudsql, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_cloudsql, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_cloudsql, [fixture_constraints], template_name)
}

#### Testing for GKE clusters
# Confirm exactly 6 GKE violations were found
# 4 GKE clusters have violations - 2 of which have 2 violations (one has 2 labels missing, the other has 2 labels with invalid values)
# confirm which 4 GKE clusters are in violation
test_enforce_label_gke_violations {
	expected_resource_names := {
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust1-invalid-missing-labels",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust2-invalid-missing-label1",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust3-invalid-missing-label2",
		"//container.googleapis.com/projects/transfer-repos/zones/us-central1-c/clusters/joe-clust4-invalid-label1-and-label2-bad-values",
	}

	test_utils.check_test_violations_count(fixture_gke, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_gke, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_gke, [fixture_constraints], template_name)
}

#### Testing for Dataproc Jobs
# 4 dataproc jobs have violations - 2 of which have 2 violations
test_enforce_label_dataproc_job_violations {
	expected_resource_names := {
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/jobs/job-b068791b-dataproc-job-missing-label1",
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/jobs/job-b068791b-dataproc-job-missing-label2",
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/jobs/job-b068791b-dataproc-job-missing-labels",
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/jobs/job-b068791b-dataproc-job-bad-values",
	}

	test_utils.check_test_violations_count(fixture_dataproc_jobs, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_dataproc_jobs, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_dataproc_jobs, [fixture_constraints], template_name)

	fixture_dataproc_clusters
}

#### Testing for Dataproc Clusters
# 4 dataproc clusters have violations - 2 of which have 2 violations (one has 2 labels missing,
# the other has 2 labels with invalid values)
test_enforce_label_dataproc_cluster_violations {
	expected_resource_names := {
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/clusters/cluster-a1b6-test-dataproc-missing-labels",
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/clusters/cluster-a1b6-test-dataproc-missing-label1",
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/clusters/cluster-a1b6-test-dataproc-missing-label2",
		"//dataproc.googleapis.com/projects/my-own-project/regions/global/clusters/cluster-a1b6-test-dataproc-bad-values",
	}

	test_utils.check_test_violations_count(fixture_dataproc_clusters, [fixture_constraints], template_name, 6)
	test_utils.check_test_violations_resources(fixture_dataproc_clusters, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_dataproc_clusters, [fixture_constraints], template_name)
}

#### Testing for BQ resources (Datasets, Tables and Views)
# Confirm exactly 12 violations were found
# 2 datasets have violations - both of them have 2 violations (missing or wrong labels)
# 2 tables have violations - both of them have 2 violations (missing or wrong labels)
# 2 views have violations - both of them have 2 violations (missing or wrong labels)
# confirm which BQ resources are in violation
test_enforce_label_bq_violations {
	expected_resource_names := {
		"//bigquery.googleapis.com/projects/cf-test-project-aw/datasets/test_dataset_1_no_labels",
		"//bigquery.googleapis.com/projects/cf-test-project-aw/datasets/test_dataset_2_wrong_labels",
		"//bigquery.googleapis.com/projects/cf-test-project-aw/datasets/test_dataset_good_labels/tables/table_wrong_labels",
		"//bigquery.googleapis.com/projects/cf-test-project-aw/datasets/test_dataset_good_labels/tables/table_no_labels",
		"//bigquery.googleapis.com/projects/cf-test-project-aw/datasets/test_dataset_1_no_labels/tables/table_valid_labels_view_no_labels",
		"//bigquery.googleapis.com/projects/cf-test-project-aw/datasets/test_dataset_2_wrong_labels/tables/table_valid_labels_view_wrong_labels",
	}

	test_utils.check_test_violations_count(fixture_bq, [fixture_constraints], template_name, 12)
	test_utils.check_test_violations_resources(fixture_bq, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_bq, [fixture_constraints], template_name)
}

#### Testing for Spanner Instances
# Confirm 2 violation, one for the CAI representation and one for the API. Each of them has 2 labels either
# missing or with incorrect values.
test_enforce_label_spanner_violations {
	expected_resource_names := {
		"//spanner.googleapis.com/projects/foobar/instances/spanner-instance-api-nolabel",
		"//spanner.googleapis.com/projects/foobar/instances/spanner-instance-cai-incorrectvalue",
	}

	test_utils.check_test_violations_count(fixture_spanner, [fixture_constraints], template_name, 4)
	test_utils.check_test_violations_resources(fixture_spanner, [fixture_constraints], template_name, expected_resource_names)
	test_utils.check_test_violations_signature(fixture_spanner, [fixture_constraints], template_name)
}
