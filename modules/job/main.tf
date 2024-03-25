
##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine job
##############################################################################

resource "ibm_code_engine_job" "ce_job" {
  project_id                    = var.project_id
  name                          = var.name
  image_reference               = var.image_reference
  image_secret                  = var.image_secret
  run_mode                      = var.run_mode
  run_arguments                 = var.run_arguments
  run_as_user                   = var.run_as_user
  run_commands                  = var.run_commands
  run_service_account           = var.run_service_account
  scale_array_spec              = var.scale_array_spec
  scale_max_execution_time      = var.scale_max_execution_time
  scale_cpu_limit               = var.scale_cpu_limit
  scale_ephemeral_storage_limit = var.scale_ephemeral_storage_limit
  scale_retry_limit             = var.scale_retry_limit
  scale_memory_limit            = var.scale_memory_limit

  dynamic "run_env_variables" {
    for_each = var.run_env_variables != null ? var.run_env_variables : []
    content {
      type      = run_env_variables.value["type"]
      name      = run_env_variables.value["name"]
      value     = run_env_variables.value["value"]
      prefix    = run_env_variables.value["prefix"]
      key       = run_env_variables.value["key"]
      reference = run_env_variables.value["reference"]
    }
  }

  dynamic "run_volume_mounts" {
    for_each = var.run_volume_mounts != null ? var.run_volume_mounts : []
    content {
      mount_path = run_volume_mounts.value["mount_path"]
      reference  = run_volume_mounts.value["reference"]
      name       = run_volume_mounts.value["name"]
      type       = run_volume_mounts.value["type"]
    }
  }
}
