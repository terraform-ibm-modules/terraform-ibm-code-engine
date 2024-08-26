########################################################################################################################
# Outputs
########################################################################################################################

output "project_name_id_map" {
  description = "Map of project names to their corresponding IDs."
  value       = { for p in module.project : p.name => p.project_id }
}

# IBM Projects Stacks do not support complex outputs at this time,
# As a workaround, we will output the first 5 projects individually. If a project does not exist, the output will be null.
output "project_1_name" {
  description = "Name of the first project."
  value       = length(module.project) > 0 ? module.project[0].name : null
}

output "project_1_id" {
  description = "ID of the first project."
  value       = length(module.project) > 0 ? module.project[0].project_id : null
}

output "project_2_name" {
  description = "Name of the second project."
  value       = length(module.project) > 1 ? module.project[1].name : null
}

output "project_2_id" {
  description = "ID of the second project."
  value       = length(module.project) > 1 ? module.project[1].project_id : null
}

output "project_3_name" {
  description = "Name of the third project."
  value       = length(module.project) > 2 ? module.project[2].name : null
}

output "project_3_id" {
  description = "ID of the third project."
  value       = length(module.project) > 2 ? module.project[2].project_id : null
}

output "project_4_name" {
  description = "Name of the fourth project."
  value       = length(module.project) > 3 ? module.project[3].name : null
}

output "project_4_id" {
  description = "ID of the fourth project."
  value       = length(module.project) > 3 ? module.project[3].project_id : null
}

output "project_5_name" {
  description = "Name of the fifth project."
  value       = length(module.project) > 4 ? module.project[4].name : null
}

output "project_5_id" {
  description = "ID of the fifth project."
  value       = length(module.project) > 4 ? module.project[4].project_id : null
}
