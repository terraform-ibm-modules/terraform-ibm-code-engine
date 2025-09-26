########################################################################################################################
# Outputs
########################################################################################################################

output "project_id" {
  description = "ID of the created code engine project."
  value       = module.code_engine.project_id
}

output "app" {
  description = "Configuration of the created code engine app."
  value       = module.code_engine.app
}

output "config_map" {
  description = "Configuration of the created code engine config map."
  value       = module.code_engine.config_map
}

output "secret" {
  description = "Configuration of the created code engine secret."
  value       = module.code_engine.secret
}

output "domain_mapping" {
  description = "Configuration of the created code engine domain mapping."
  value       = module.code_engine.domain_mapping
}

output "binding" {
  description = "Configuration of the created code engine binding."
  value       = module.code_engine.binding
}
