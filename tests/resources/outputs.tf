########################################################################################################################
# Outputs
########################################################################################################################
output "tls_cert" {
  value     = format("%s%s", data.ibm_sm_public_certificate.public_certificate.certificate, data.ibm_sm_public_certificate.public_certificate.intermediate)
  sensitive = true
}

output "tls_key" {
  value     = data.ibm_sm_public_certificate.public_certificate.private_key
  sensitive = true
}

output "cr_name" {
  value = module.namespace.namespace_name
}
