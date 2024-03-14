########################################################################################################################
# Outputs
########################################################################################################################

output "app_id" {
  description = "The ID of the created code engine app."
  value       = resource.ibm_code_engine_app.ce_app.app_id
}

output "id" {
  description = "The unique identifier of the created code engine app."
  value       = resource.ibm_code_engine_app.ce_app.id
}
