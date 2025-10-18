########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  description = "The id of created resource group."
  value       = module.resource_group.resource_group_id
}

output "resource_group_name" {
  description = "The name of created resource group."
  value       = module.resource_group.resource_group_name
}

output "project_id" {
  description = "ID of the created code engine project."
  value       = module.code_engine.project_id
}

output "build" {
  description = "Configuration of the created code engine domain mapping."
  value       = module.code_engine.build
  sensitive   = true
}
