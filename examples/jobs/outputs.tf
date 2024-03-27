########################################################################################################################
# Outputs
########################################################################################################################

output "project_id" {
  description = "ID of the created code engine project."
  value       = module.code_engine.project_id
}

output "job" {
  description = "Configuration of the created code engine job."
  value       = module.code_engine.job
}

output "secret" {
  description = "Configuration of the created code engine secret."
  value       = module.code_engine.secret
}

output "build" {
  description = "Configuration of the created code engine build."
  value       = module.code_engine.build
}
