########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5 "
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

########################################################################################################################
# Code Engine instance
########################################################################################################################

module "code_engine" {
  source              = "../.."
  resource_group_id   = module.resource_group.resource_group_id
  project_name        = var.project_name
  existing_project_id = var.existing_project_id
  apps = {
    # tflint-ignore: terraform_deprecated_interpolation
    "${var.app_name}" = {
      image_reference               = var.image_reference
      image_secret                  = var.image_secret
      run_env_variables             = var.run_env_variables
      run_volume_mounts             = var.run_volume_mounts
      image_port                    = var.image_port
      managed_domain_mappings       = var.managed_domain_mappings
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
  } }
  config_maps     = var.config_maps
  secrets         = var.secrets
  domain_mappings = var.domain_mappings
  bindings        = var.bindings
}
