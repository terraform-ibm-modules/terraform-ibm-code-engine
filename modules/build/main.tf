##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine build
##############################################################################

resource "ibm_code_engine_build" "ce_build" {
  project_id    = var.project_id
  name          = var.name
  output_image  = var.output_image
  output_secret = var.output_secret
  source_url    = var.source_url
  strategy_type = var.strategy_type

}
