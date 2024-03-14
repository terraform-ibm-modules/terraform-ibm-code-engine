##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine binding
##############################################################################

resource "ibm_code_engine_binding" "ce_binding" {
  project_id  = var.project_id
  prefix      = var.prefix
  secret_name = var.secret_name

  dynamic "component" {
    for_each = var.components != null ? var.components : []
    content {
      name          = component.value["name"]
      resource_type = component.value["resource_type"]
    }
  }
}
