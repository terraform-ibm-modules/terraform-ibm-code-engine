########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_name" {
  description = "Name of the resource group."
  value       = module.resource_group.resource_group_name
}

output "code_engine_project_name" {
  description = "Name of the code engine project."
  value       = module.project.name
}

output "code_engine_project_id" {
  description = "Id of the code engine project."
  value       = module.project.id
}

output "tasks_state_store_name" {
  description = "Name of the task state store."
  value       = local.bucket_store_map[local.bucket_store_map]
}

output "cloud_logs_name" {
  description = "Name of the cloud logs instance."
  value       = module.cloud_logs.name
}

output "cloud_logs_crn" {
  description = "CRN of the cloud logs instance."
  value       = module.cloud_logs.crn
}

output "cloud_monitoring__crn" {
  description = "CRN of the cloud monitoring instance."
  value       = module.cloud_monitoring.crn
}

output "cloud_monitoring_crn" {
  description = "Name of the cloud monitoring instance."
  value       = module.cloud_monitoring.name
}

output "cloud_object_storage_crn" {
  description = "Name of the cloud object storage instance."
  value       = module.cos.cos_instance_name
}

output "next_steps_text" {
  value       = "Now, visit the Code Engine project URL to verify secrets, network configurations, and ensure readiness for workload deployment."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Go to Code Engine Project"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://cloud.ibm.com/containers/serverless/project/${var.region}/${module.project.id}/overview"
  description = "primary url"
}


    