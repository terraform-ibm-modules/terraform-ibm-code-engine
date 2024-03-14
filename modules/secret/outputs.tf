########################################################################################################################
# Outputs
########################################################################################################################

output "secret_id" {
  description = "The ID of the created code engine secret."
  value       = resource.ibm_code_engine_secret.ce_secret.secret_id
}

output "id" {
  description = "The unique identifier of the created code engine secret."
  value       = resource.ibm_code_engine_secret.ce_secret.id
}
