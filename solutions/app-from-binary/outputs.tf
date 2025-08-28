########################################################################################################################
# Outputs
########################################################################################################################

output "project_id" {
  description = "ID of the created code engine project."
  value       = module.project.project_id
}

output "app" {
  description = "Configuration of the created code engine app."
  value       = module.app
}

output "secret" {
  description = "Configuration of the created code engine secret."
  value       = module.secret
}
