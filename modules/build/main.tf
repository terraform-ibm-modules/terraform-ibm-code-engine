##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine build
##############################################################################

resource "ibm_code_engine_build" "ce_build" {
  project_id         = var.project_id
  name               = var.name
  output_image       = var.output_image
  output_secret      = var.output_secret
  source_url         = var.source_url
  source_context_dir = var.source_context_dir
  source_revision    = var.source_revision
  source_secret      = var.source_secret
  source_type        = var.source_type
  strategy_type      = var.strategy_type
  strategy_size      = var.strategy_size
  strategy_spec_file = var.strategy_spec_file
  timeout            = var.timeout
}
