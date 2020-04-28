output "nonprod_project_id" {
  value       = module.nonprod_project.project_id
  description = "The project where application-related infrastructure will reside."
}

output "nonprod_network_project_id" {
  value       = local.nonprod_host_network.project
  description = "The network project where hosts the shared vpc used by the project created for nonprod environment."
}

output "nonprod_network_name" {
  value       = local.nonprod_host_network.name
  description = "The name of Shared VPC used by the project created for nonprod environment."
}

output "prod_project_id" {
  value       = module.prod_project.project_id
  description = "The project where application-related infrastructure will reside for prod environment."
}

output "prod_network_project_id" {
  value       = local.prod_host_network.project
  description = "The network project where hosts the shared vpc used by the project created for prod environment."
}

output "prod_network_name" {
  value       = local.prod_host_network.name
  description = "The name of Shared VPC used by the project created for prod environment."
}