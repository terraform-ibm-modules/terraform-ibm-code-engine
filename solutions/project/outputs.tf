########################################################################################################################
# Outputs
########################################################################################################################

output "project_name" {
  description = "Name of the project."
  value       = module.project.name
}

output "project_id" {
  description = "ID of the project."
  value       = module.project.project_id
}
