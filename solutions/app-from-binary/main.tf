locals {
  prefix       = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  project_name = "${local.prefix}${var.project_name}"
  app_name     = "${local.prefix}${var.app_name}"
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

  # if no build defines a container image reference (output_image), a new container registry namespace must be created using container_registry_namespace.
  # any_missing_output_image = anytrue([
  #   for build in values(var.builds) :
  #   !contains(keys(build), "output_image") || build.output_image == null
  # ])

  # if output_image not exists then a new created container image reference
  # updated_builds = {
  #   for name, build in var.builds :
  #   name => merge(
  #     build,
  #     {
  #       output_image = coalesce(build.output_image, "${local.image_container}/${name}")
  #     }
  #   )
  # }

}

data "external" "container_registry_region" {
  program = ["bash", "../${path.module}/scripts/get-cr-region.sh"]

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
    for name, secret in nonsensitive(local.secrets) : name
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
  # github_secret_name = "${local.prefix}github-secret"
  # github_secret = var.github_password != null && var.github_username != null ? {
  #   (local.github_secret_name) = {
  #     format = "generic"
  #     "data" = {
  #       "password" = var.github_password,
  #       username   = var.github_username
  #     }
  #   }
  # } : {}

  registry_secret_name = "${local.prefix}registry-secret"
  registry_secret = {
    (local.registry_secret_name) = {
      format = "registry"
      "data" = {
        password = var.ibmcloud_api_key,
        username = "iamapikey",
        server   = local.container_registry
      }
    }
  }

  secrets = merge(local.registry_secret)

  # secrets_for_each = {
  #   for key, val in local.secrets : key => {
  #     format = val.format
  #     # Leave out sensitive data from for_each evaluation
  #   }
  # }

  # registry_secret_names = [
  #   for name, secret in var.secrets : name
  #   if secret.format == "registry"
  # ]
  # has_registry = length(local.registry_secret_names) > 0



  # secrets = local.has_registry ? var.secrets : merge(
  #   var.secrets,
  #   {
  #     (local.registry_secret_name) = {
  #       format = "registry"
  #       data = {
  #         password = var.ibmcloud_api_key,
  #         username = "iamapikey",
  #         server   = local.container_registry
  #       }
  #     }
  #   }
  # )

}

module "secret" {
  source     = "../../modules/secret"
  for_each   = nonsensitive(local.secrets)
  project_id = module.project.project_id
  name       = each.key
  data       = each.value.data
  format     = each.value.format
  # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
  # service_access = each.value.service_access
}

##############################################################################
# Code Engine Apps
##############################################################################
locals {
  image_reference = var.app_image_reference

  app_scale_cpu_limit    = tonumber(regex("^([0-9.]+)", var.app_scale_cpu_memory)[0])
  app_scale_memory_limit = tonumber(regex("/ ([0-9.]+)", var.app_scale_cpu_memory)[0])
}

module "app" {
  source = "../../modules/app"
  # count                         = var.app == null ? 0 : 1
  name            = local.app_name
  image_reference = local.image_reference
  image_secret    = var.app_image_secret != null ? var.app_image_secret : local.registry_secret_name
  project_id      = module.project.project_id

  image_port = var.app_image_port
  # run_arguments       = var.run_arguments
  # run_as_user         = var.run_as_user
  # run_commands        = var.run_commands
  # run_env_variables   = var.run_env_variables
  # run_service_account = var.run_service_account
  # run_volume_mounts   = var.run_volume_mounts
  managed_domain_mappings       = var.managed_domain_mappings
  scale_concurrency             = var.app_scale_concurrency
  scale_concurrency_target      = var.app_scale_concurrency_target
  scale_cpu_limit               = var.app_scale_cpu_limit != null ? var.app_scale_cpu_limit : local.app_scale_cpu_limit
  scale_down_delay              = var.app_scale_down_delay
  scale_ephemeral_storage_limit = var.app_scale_ephemeral_storage_limit
  # scale_initial_instances       = var.app.scale_initial_instances
  # scale_max_instances           = var.app.scale_max_instances
  scale_memory_limit = var.app_scale_memory_limit != null ? var.app_scale_memory_limit : local.app_scale_memory_limit
  # scale_min_instances           = var.app.scale_min_instances
  scale_request_timeout = var.app_scale_request_timeout

}

##############################################################################
# Code Engine Bindings
##############################################################################

module "binding" {
  source      = "../../modules/binding"
  for_each    = var.bindings
  secret_name = each.value.secret_name
  components  = each.value.components
  project_id  = module.project.project_id
  prefix      = local.prefix
}
