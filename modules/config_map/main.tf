##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine config map
##############################################################################

resource "ibm_code_engine_config_map" "ce_config_map" {
  project_id = var.project_id
  name       = var.name
  data       = var.data
}
