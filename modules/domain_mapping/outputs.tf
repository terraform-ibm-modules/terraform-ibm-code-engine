########################################################################################################################
# Outputs
########################################################################################################################

output "domain_mapping_id" {
  description = "The ID of the created code engine domain mapping."
  value       = resource.ibm_code_engine_domain_mapping.ce_domain_mapping.domain_mapping_id
}

output "id" {
  description = "The unique identifier of the created code engine domain mapping."
  value       = resource.ibm_code_engine_domain_mapping.ce_domain_mapping.id
}
