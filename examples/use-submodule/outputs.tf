########################################################################################################################
# Outputs
########################################################################################################################

output "project_id" {
  description = "ID of the created code engine project."
  value       = module.ce_project.project_id
}

output "app" {
  description = "Configuration of the created code engine app."
  value       = module.ce_app
}
