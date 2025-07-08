locals {
  prefix       = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  project_name = "${local.prefix}${var.project_name}"
  app_name     = "${local.prefix}${var.app.name}"
}

########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "../../modules/project"
  name              = local.project_name
  resource_group_id = module.resource_group.resource_group_id
  cbr_rules         = var.cbr_rules
}

##############################################################################
# Code Engine Build
##############################################################################
locals {
  registry_region_result = data.external.container_registry_region.result
  registry               = lookup(local.registry_region_result, "registry", null)
  container_registry     = local.registry != null ? "private.${local.registry}" : null
  registry_region_error  = lookup(local.registry_region_result, "error", null)

  # This will cause Terraform to fail if "error" is present in the external script output executed as a part of container_registry_region
  # tflint-ignore: terraform_unused_declarations
  fail_if_registry_region_error = local.registry_region_error != null ? tobool("Registry region script failed: ${local.registry_region_error}") : null
}

data "external" "container_registry_region" {
  program = ["bash", "${path.module}/../scripts/get-cr-region.sh"]

  query = {
    RESOURCE_GROUP_ID = module.resource_group.resource_group_id
    REGION            = var.region
    IBMCLOUD_API_KEY  = var.ibmcloud_api_key
  }
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
locals {
  # return tls secrets
  tls_secret_names = [
    for name, secret in local.secrets : name
    if secret.format == "tls"
  ]
  # use the value of the first tls secret if exists
  tls_secret_name = length(local.tls_secret_names) > 0 ? local.tls_secret_names[0] : null
}

module "domain_mapping" {
  depends_on = [module.secret]
  source     = "../../modules/domain_mapping"
  for_each   = var.domain_mappings
  project_id = module.project.project_id
  name       = each.key
  tls_secret = each.value.tls_secret != null ? each.value.tls_secret : local.tls_secret_name
  components = each.value.components
}

##############################################################################
# Code Engine Config Map
##############################################################################
module "config_map" {
  source     = "../../modules/config_map"
  for_each   = var.config_maps
  project_id = module.project.project_id
  name       = each.key
  data       = each.value.data
}

##############################################################################
# Code Engine Secret
##############################################################################
locals {
  registry_secret_names = [
    for name, secret in var.secrets : name
    if secret.format == "registry"
  ]
  has_registry = length(local.registry_secret_names) > 0

  registry_name = local.has_registry ? local.registry_secret_names[0] : "${local.prefix}registry"
  secrets = local.has_registry ? var.secrets : merge(
    var.secrets,
    {
      (local.registry_name) = {
        format = "registry"
        data = {
          password = var.ibmcloud_api_key,
          username = "iamapikey",
          server   = local.container_registry
        }
      }
    }
  )
}

module "secret" {
  source     = "../../modules/secret"
  for_each   = local.secrets
  project_id = module.project.project_id
  name       = each.key
  data       = sensitive(each.value.data)
  format     = each.value.format
  # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
  # service_access = each.value.service_access
}

##############################################################################
# Code Engine Apps
##############################################################################

module "app" {
  source                        = "../../modules/app"
  count                         = var.app == null ? 0 : 1
  image_port                    = var.app.image_port
  image_reference               = var.app.image_reference
  image_secret                  = var.app.image_secret != null ? var.app.image_secret : local.registry_name
  managed_domain_mappings       = var.app.managed_domain_mappings
  name                          = local.app_name
  project_id                    = module.project.project_id
  run_arguments                 = var.app.run_arguments
  run_as_user                   = var.app.run_as_user
  run_commands                  = var.app.run_commands
  run_env_variables             = var.app.run_env_variables
  run_service_account           = var.app.run_service_account
  run_volume_mounts             = var.app.run_volume_mounts
  scale_concurrency             = var.app.scale_concurrency
  scale_concurrency_target      = var.app.scale_concurrency_target
  scale_cpu_limit               = var.app.scale_cpu_limit
  scale_down_delay              = var.app.scale_down_delay
  scale_ephemeral_storage_limit = var.app.scale_ephemeral_storage_limit
  scale_initial_instances       = var.app.scale_initial_instances
  scale_max_instances           = var.app.scale_max_instances
  scale_memory_limit            = var.app.scale_memory_limit
  scale_min_instances           = var.app.scale_min_instances
  scale_request_timeout         = var.app.scale_request_timeout
}

output "name" {
  value = local.registry_name
}
