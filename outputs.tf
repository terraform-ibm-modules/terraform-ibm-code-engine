########################################################################################################################
# Outputs
########################################################################################################################

output "project_id" {
  description = "ID of the created code engine project."
  value       = local.project_id
}

output "app" {
  description = "Configuration of the created code engine app."
  value       = module.app
}

output "job" {
  description = "Configuration of the created code engine job."
  value       = module.job
}

output "config_map" {
  description = "Configuration of the created code engine config map."
  value       = module.config_map
}

output "secret" {
  description = "Configuration of the created code engine secret."
  value       = module.secret
  sensitive   = true
}

output "build" {
  description = "Configuration of the created code engine build."
  value       = module.build
}

output "binding" {
  description = "Configuration of the created code engine binding."
  value       = module.binding
}

output "domain_mapping" {
  description = "Configuration of the created code engine domain maping."
  value       = module.domain_mapping
}
