##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine domain mapping
##############################################################################

resource "ibm_code_engine_domain_mapping" "ce_domain_mapping" {
  project_id = var.project_id
  name       = var.name
  tls_secret = var.tls_secret
  dynamic "component" {
    for_each = var.components
    content {
      name          = component.value["name"]
      resource_type = component.value["resource_type"]
    }
  }
}
