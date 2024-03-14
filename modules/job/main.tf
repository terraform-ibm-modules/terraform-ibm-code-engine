
##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine job
##############################################################################

resource "ibm_code_engine_job" "ce_job" {
  project_id      = var.project_id
  name            = var.name
  image_reference = var.image_reference

  dynamic "run_env_variables" {
    for_each = var.run_env_variables != null ? var.run_env_variables : []
    content {
      type  = run_env_variables.value["type"]
      name  = run_env_variables.value["name"]
      value = run_env_variables.value["value"]
    }
  }
}
