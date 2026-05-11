output "cloudbuild_project_id" {
  description = "Project where Cloud Build configuration and terraform container image will reside."
  value       = module.cloudbuild_project.project_id
}

output "csr_repos" {
  description = "Cloud Source Repositories created in the Cloud Build project."
  value = {
    for key, repo in google_sourcerepo_repository.gcp_repo : key => {
      id      = repo.id
      name    = repo.name
      project = repo.project
      url     = repo.url
    }
  }
}
