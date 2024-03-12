########################################################################################################################
# Outputs
########################################################################################################################

output "projects" {
  description = "Created code engine projects."
  value       = resource.ibm_code_engine_project.ce_project
}

output "apps" {
  description = "Created code engine apps."
  value       = resource.ibm_code_engine_app.ce_app
}

output "config_maps" {
  description = "Created code engine config_maps."
  value       = resource.ibm_code_engine_config_map.ce_config_map
}

output "jobs" {
  description = "Created code engine jobs."
  value       = resource.ibm_code_engine_job.ce_job
}

output "builds" {
  description = "Created code engine builds."
  value       = resource.ibm_code_engine_build.ce_build
}

output "bindings" {
  description = "Created code engine bindings."
  value       = resource.ibm_code_engine_binding.ce_binding
}

output "domain_mappings" {
  description = "Created code engine domain_mappings."
  value       = resource.ibm_code_engine_domain_mapping.ce_domain_mapping
}

output "secrets" {
  description = "Created code engine secrets."
  value       = resource.ibm_code_engine_secret.code_engine_secret_instance
  sensitive   = true
}
