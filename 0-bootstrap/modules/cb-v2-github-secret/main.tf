data "google_project" "project_id" {
  project_id = var.project_id
}

resource "google_secret_manager_secret" "github_token_secret" {

  project   = var.project_id
  secret_id = var.secret_id

  replication {
    auto {

    }
  }
}

resource "google_secret_manager_secret_version" "github_token_secret_version" {
  secret      = google_secret_manager_secret.github_token_secret.id
  secret_data = var.github_pat
}

resource "google_secret_manager_secret_iam_member" "accessor" {
  secret_id = google_secret_manager_secret.github_token_secret.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:service-${data.google_project.project_id.number}@gcp-sa-cloudbuild.iam.gserviceaccount.com"
}
