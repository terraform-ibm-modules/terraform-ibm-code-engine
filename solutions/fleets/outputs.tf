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
  value       = local.bucket_store_map[local.taskstore_bucket_name]
}

output "cloud_logs_name" {
  description = "Name of the cloud logs instance."
  value       = var.enable_cloud_logs ? module.cloud_logs[0].name : null
}

output "cloud_logs_crn" {
  description = "CRN of the cloud logs instance."
  value       = var.enable_cloud_logs ? module.cloud_logs[0].crn : null
}

output "cloud_monitoring_crn" {
  description = "CRN of the cloud monitoring instance."
  value       = local.enable_cloud_monitoring ? module.cloud_monitoring[0].crn : null
}

output "cloud_monitoring_name" {
  description = "Name of the cloud monitoring instance."
  value       = local.enable_cloud_monitoring ? module.cloud_monitoring[0].name : null
}

output "cloud_object_storage_crn" {
  description = "Name of the cloud object storage instance."
  value       = module.cos.cos_instance_name
}

output "vpc_crn" {
  description = "CRN of the VPC."
  value       = module.vpc.vpc_crn
}

output "vpc_name" {
  description = "Name of the VPC."
  value       = module.vpc.vpc_name
}

output "next_steps_text" {
  value       = "Now, visit the documentation to learn how to run a serverless fleet using Code Engine."
  description = "Next steps text"
}

output "next_step_primary_label" {
  value       = "Learn how to run a serverless fleet"
  description = "Primary label"
}

output "next_step_primary_url" {
  value       = "https://github.com/IBM/CodeEngine/blob/main/beta/serverless-fleets/README.md#launch-a-fleet"
  description = "primary url"
}
