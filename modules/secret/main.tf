##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine secret
##############################################################################

resource "ibm_code_engine_secret" "ce_secret" {
  project_id = var.project_id
  name       = var.name
  format     = var.format
  data       = var.data
}
