########################################################################################################################
# Outputs
########################################################################################################################

output "project_ids" {
  description = "List of IDs of the created code engine projects."
  value       = [for p in module.project : p.project_id]
}

output "project_names" {
  description = "List of names of the created code engine projects."
  value       = [for p in module.project : p.name]
}
