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

output "config_map" {
  description = "Configuration of the created code engine config map."
  value       = module.config_map
}

output "secret" {
  description = "Configuration of the created code engine secret."
  value       = module.secret
}

output "domain_mapping" {
  description = "Configuration of the created code engine domain maping."
  value       = module.domain_mapping
}

output "build" {
  description = "Configuration of the created code engine build."
  value       = module.build
}

output "app" {
  description = "Configuration of the created code engine app."
  value       = module.app
}

output "binding" {
  description = "Configuration of the created code engine binding."
  value       = module.binding
}
