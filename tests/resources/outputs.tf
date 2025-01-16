########################################################################################################################
# Outputs
########################################################################################################################
output "tls_cert" {
  value       = format("%s%s", data.ibm_sm_public_certificate.public_certificate.certificate, data.ibm_sm_public_certificate.public_certificate.intermediate)
  sensitive   = true
  description = "The TLS certificate."
}

output "tls_key" {
  value       = data.ibm_sm_public_certificate.public_certificate.private_key
  sensitive   = true
  description = "The TLS private key."
}

output "cr_name" {
  value       = module.namespace.namespace_name
  description = "The name of the container registry namespace."
}
