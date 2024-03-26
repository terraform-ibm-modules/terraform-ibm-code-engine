########################################################################################################################
# Outputs
########################################################################################################################

output "config_map_id" {
  description = "The ID of the created code engine config map."
  value       = resource.ibm_code_engine_config_map.ce_config_map.config_map_id
}

output "id" {
  description = "The unique identifier of the created code engine config map."
  value       = resource.ibm_code_engine_config_map.ce_config_map.id
}

output "data" {
  description = "The code engine config map's data."
  value       = resource.ibm_code_engine_config_map.ce_config_map.data
}

output "name" {
  description = "The name of the created code engine config map."
  value       = resource.ibm_code_engine_config_map.ce_config_map.name
}
