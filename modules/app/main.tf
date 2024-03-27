##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine apps
##############################################################################

resource "ibm_code_engine_app" "ce_app" {
  project_id                    = var.project_id
  name                          = var.name
  image_reference               = var.image_reference
  image_secret                  = var.image_secret
  managed_domain_mappings       = var.managed_domain_mappings
  image_port                    = var.image_port
  run_arguments                 = var.run_arguments
  run_as_user                   = var.run_as_user
  run_commands                  = var.run_commands
  run_service_account           = var.run_service_account
  scale_concurrency             = var.scale_concurrency
  scale_concurrency_target      = var.scale_concurrency_target
  scale_cpu_limit               = var.scale_cpu_limit
  scale_ephemeral_storage_limit = var.scale_ephemeral_storage_limit
  scale_initial_instances       = var.scale_initial_instances
  scale_max_instances           = var.scale_max_instances
  scale_memory_limit            = var.scale_memory_limit
  scale_min_instances           = var.scale_min_instances
  scale_request_timeout         = var.scale_request_timeout


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
