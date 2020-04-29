output "project_id" {
  value       = module.project.project_id
  description = "The project where application-related infrastructure will reside."
}

output "network_project_id" {
  value       = local.host_network.project
  description = "The network project where hosts the shared vpc used by the project created."
}

output "network_name" {
  value       = local.host_network.name
  description = "The name of Shared VPC used by the project created."
}

output "environment" {
  value       = var.environment
  description = "The environment the single project belongs to"
}
