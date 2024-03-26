########################################################################################################################
# Outputs
########################################################################################################################

output "job_id" {
  description = "The ID of the created code engine job."
  value       = resource.ibm_code_engine_job.ce_job.job_id
}

output "id" {
  description = "The unique identifier of the created code engine job."
  value       = resource.ibm_code_engine_job.ce_job.id
}

output "name" {
  description = "The name of the created code engine job."
  value       = resource.ibm_code_engine_job.ce_job.name
}
