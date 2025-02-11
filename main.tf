locals {
  project_id = var.project_name == null ? var.existing_project_id : module.project[0].id
  # tflint-ignore: terraform_unused_declarations
  validate_project_name_id = (var.project_name != null && var.existing_project_id != null) || (var.project_name == null && var.existing_project_id == null) ? tobool("Please provide exactly one of var.project_name or var.existing_project_id. Passing neither or both is invalid.") : true
}

##############################################################################
# Code Engine Project
##############################################################################
module "project" {
  count             = var.existing_project_id != null ? 0 : 1
  source            = "./modules/project"
  name              = var.project_name
  resource_group_id = var.resource_group_id
  cbr_rules         = var.cbr_rules
}

##############################################################################
# Code Engine App
##############################################################################
module "app" {
  depends_on                    = [module.secret, module.config_map]
  source                        = "./modules/app"
  for_each                      = var.apps
  project_id                    = local.project_id
  name                          = each.key
  image_reference               = each.value.image_reference
  image_secret                  = each.value.image_secret
  image_port                    = each.value.image_port
  run_env_variables             = each.value.run_env_variables
  run_volume_mounts             = each.value.run_volume_mounts
  managed_domain_mappings       = each.value.managed_domain_mappings
  run_arguments                 = each.value.run_arguments
  run_as_user                   = each.value.run_as_user
  run_commands                  = each.value.run_commands
  run_service_account           = each.value.run_service_account
  scale_concurrency             = each.value.scale_concurrency
  scale_concurrency_target      = each.value.scale_concurrency_target
  scale_cpu_limit               = each.value.scale_cpu_limit
  scale_ephemeral_storage_limit = each.value.scale_ephemeral_storage_limit
  scale_initial_instances       = each.value.scale_initial_instances
  scale_max_instances           = each.value.scale_max_instances
  scale_memory_limit            = each.value.scale_memory_limit
  scale_min_instances           = each.value.scale_min_instances
  scale_request_timeout         = each.value.scale_request_timeout
  scale_down_delay              = each.value.scale_down_delay
}

##############################################################################
# Code Engine Job
##############################################################################
module "job" {
  depends_on                    = [module.secret, module.config_map]
  source                        = "./modules/job"
  for_each                      = var.jobs
  project_id                    = local.project_id
  name                          = each.key
  image_reference               = each.value.image_reference
  image_secret                  = each.value.image_secret
  run_env_variables             = each.value.run_env_variables
  run_volume_mounts             = each.value.run_volume_mounts
  run_arguments                 = each.value.run_arguments
  run_as_user                   = each.value.run_as_user
  run_commands                  = each.value.run_commands
  run_mode                      = each.value.run_mode
  run_service_account           = each.value.run_service_account
  scale_array_spec              = each.value.scale_array_spec
  scale_cpu_limit               = each.value.scale_cpu_limit
  scale_ephemeral_storage_limit = each.value.scale_ephemeral_storage_limit
  scale_max_execution_time      = each.value.scale_max_execution_time
  scale_memory_limit            = each.value.scale_memory_limit
  scale_retry_limit             = each.value.scale_retry_limit
}

##############################################################################
# Code Engine Config Map
##############################################################################
module "config_map" {
  source     = "./modules/config_map"
  for_each   = var.config_maps
  project_id = local.project_id
  name       = each.key
  data       = each.value.data
}

##############################################################################
# Code Engine Secret
##############################################################################
module "secret" {
  source     = "./modules/secret"
  for_each   = var.secrets
  project_id = local.project_id
  name       = each.key
  data       = sensitive(each.value.data)
  format     = each.value.format
  # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
  # service_access = each.value.service_access
}

##############################################################################
# Code Engine Build
##############################################################################
module "build" {
  depends_on         = [module.secret]
  source             = "./modules/build"
  for_each           = var.builds
  project_id         = local.project_id
  name               = each.key
  output_image       = each.value.output_image
  output_secret      = each.value.output_secret
  source_url         = each.value.source_url
  strategy_type      = each.value.strategy_type
  source_context_dir = each.value.source_context_dir
  source_revision    = each.value.source_revision
  source_secret      = each.value.source_secret
  source_type        = each.value.source_type
  strategy_size      = each.value.strategy_size
  strategy_spec_file = each.value.strategy_spec_file
  timeout            = each.value.timeout

}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
module "domain_mapping" {
  depends_on = [module.secret, module.app]
  source     = "./modules/domain_mapping"
  for_each   = var.domain_mappings
  project_id = local.project_id
  name       = each.key
  tls_secret = each.value.tls_secret
  components = each.value.components
}

##############################################################################
# Code Engine Binding
##############################################################################
module "binding" {
  depends_on  = [module.app, module.job]
  source      = "./modules/binding"
  for_each    = var.bindings
  project_id  = local.project_id
  prefix      = each.key
  secret_name = each.value.secret_name
  components  = each.value.components
}
