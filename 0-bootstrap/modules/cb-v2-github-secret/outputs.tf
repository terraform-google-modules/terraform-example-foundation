output "secret_id" {
  description = "Secret ID that was created. Constains the github token."
  value       = google_secret_manager_secret_version.github_token_secret_version.id
}
