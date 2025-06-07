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

output "name" {
  description = "The name of the created code engine build."
  value       = resource.ibm_code_engine_build.ce_build.name
}

output "output_image" {
  description = "The container image reference of the created code engine build."
  value       = resource.ibm_code_engine_build.ce_build.output_image
}

output "output_secret" {
  description = "The registry secret of the created code engine build."
  value       = resource.ibm_code_engine_build.ce_build.output_secret
}
