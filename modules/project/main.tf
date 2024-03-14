##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine project
##############################################################################

resource "ibm_code_engine_project" "ce_project" {
  name              = var.name
  resource_group_id = var.resource_group_id
}
