########################################################################################################################
# Outputs
########################################################################################################################

output "projects" {
  description = "Created code engine projects."
  value       = module.code_engine.projects
}

output "apps" {
  description = "Created code engine apps."
  value       = module.code_engine.apps
}

output "jobs" {
  description = "Created code engine jobs."
  value       = module.code_engine.jobs
}

output "config_maps" {
  description = "Created code engine config_maps."
  value       = module.code_engine.config_maps
}

output "builds" {
  description = "Created code engine builds."
  value       = module.code_engine.builds
}

output "bindings" {
  description = "Created code engine bindings."
  value       = module.code_engine.bindings
}

output "domain_mappings" {
  description = "Created code engine domain mappings."
  value       = module.code_engine.domain_mappings
}

output "secrets" {
  description = "Created code engine secrets."
  value       = module.code_engine.secrets
  sensitive   = true
}
