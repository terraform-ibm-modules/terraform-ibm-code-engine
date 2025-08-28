########################################################################################################################
# Outputs
########################################################################################################################

output "project_name" {
  description = "Name of the project."
  value       = module.project.name
}

output "project_id" {
  description = "ID of the created code engine project."
  value       = module.project.project_id
}

output "secret" {
  description = "Configuration of the created code engine secret."
  value       = module.secret
}

output "build" {
  description = "Configuration of the created code engine build."
  value       = module.build
}
