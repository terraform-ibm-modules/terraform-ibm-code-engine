########################################################################################################################
# Outputs
########################################################################################################################

output "build_id" {
  description = "The ID of the created code engine build."
  value       = resource.ibm_code_engine_build.ce_build.build_id
}

output "id" {
  description = "The unique identifier of the created code engine build."
  value       = resource.ibm_code_engine_build.ce_build.id
}
