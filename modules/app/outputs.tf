########################################################################################################################
# Outputs
########################################################################################################################

output "app_id" {
  description = "The ID of the created code engine app."
  value       = resource.ibm_code_engine_app.ce_app.app_id
}

output "id" {
  description = "The unique identifier of the created code engine app."
  value       = resource.ibm_code_engine_app.ce_app
}


output "endpoint" {
  description = "URL to application. Depending on visibility this is accessible publicly or in the private network only."
  value       = resource.ibm_code_engine_app.ce_app.endpoint
}


output "endpoint_internal" {
  description = "URL to application that is only visible within the project."
  value       = resource.ibm_code_engine_app.ce_app.endpoint_internal
}
