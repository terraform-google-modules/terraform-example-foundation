output "seed_project_id" {
  description = "Project where service accounts and core APIs will be enabled."
  value       = module.seed_project.project_id
}

output "gcs_bucket_tfstate" {
  description = "Bucket used for storing terraform state for foundations pipelines in seed project."
  value       = google_storage_bucket.org_terraform_state.name
}
