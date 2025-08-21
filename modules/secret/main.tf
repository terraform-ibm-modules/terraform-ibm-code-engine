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

  # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
  dynamic "service_access" {
    for_each = var.service_access != null ? var.service_access : []
    content {
      dynamic "resource_key" {
        for_each = service_access.value["resource_key"] != null ? service_access.value["resource_key"] : []
        content {
          id = resource_key.value["id"]
        }
      }
      dynamic "role" {
        for_each = service_access.value["role"] != null ? service_access.value["role"] : []
        content {
          crn = role.value["crn"]
        }
      }
      dynamic "service_instance" {
        for_each = service_access.value["service_instance"] != null ? service_access.value["service_instance"] : []
        content {
          id = service_instance.value["id"]
        }
      }
    }
  }

  lifecycle {
    ignore_changes = all
  }
}
