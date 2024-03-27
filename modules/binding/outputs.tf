########################################################################################################################
# Outputs
########################################################################################################################

output "binding_id" {
  description = "The ID of the created code engine binding."
  value       = resource.ibm_code_engine_binding.ce_binding.binding_id
}

output "id" {
  description = "The unique identifier of the created code engine binding."
  value       = resource.ibm_code_engine_binding.ce_binding.id
}
