########################################################################################################################
# Outputs
########################################################################################################################

output "id" {
  description = "The unique identifier of the created code engine project."
  value       = resource.ibm_code_engine_project.ce_project.id
}

output "project_id" {
  description = "The ID of the created code engine project."
  value       = resource.ibm_code_engine_project.ce_project.project_id
}
