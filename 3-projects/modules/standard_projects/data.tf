data "google_projects" "projects-prod" {
  filter = "labels.application_name=org-shared-vpc-prod"
}

data "google_projects" "projects-nonprod" {
  filter = "labels.application_name=org-shared-vpc-nonprod"
}

data "google_compute_network" "shared-vpc-prod" {
  name    = "shared-vpc-prod"
  project = data.google_projects.projects-prod.projects[0].project_id
}

data "google_compute_network" "shared-vpc-nonprod" {
  name    = "shared-vpc-nonprod"
  project = data.google_projects.projects-nonprod.projects[0].project_id
}

data "google_projects" "projects-monitoring-prod" {
  filter = "labels.application_name=monitoring-prod"
}

data "google_projects" "projects-monitoring-nonprod" {
  filter = "labels.application_name=monitoring-nonprod"
}