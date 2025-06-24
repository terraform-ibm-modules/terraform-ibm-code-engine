########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

########################################################################################################################
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "../../modules/project"
  name              = "${local.prefix}${var.project_name}"
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
  any_missing_output_image = anytrue([
    for build in values(var.builds) :
    !contains(keys(build), "output_image") || build.output_image == null
  ])
  image_container = local.any_missing_output_image && local.container_registry != null ? "${local.container_registry}/${resource.ibm_cr_namespace.my_namespace[0].name}" : ""

  # if output_image not exists then a new created container image reference
  updated_builds = {
    for name, build in var.builds :
    name => merge(
      build,
      {
        output_image = coalesce(build.output_image, "${local.image_container}/${name}")
      }
    )
  }
}

resource "ibm_cr_namespace" "my_namespace" {
  count = local.any_missing_output_image && var.container_registry_namespace != null ? 1 : 0
  name  = var.container_registry_namespace
}

data "external" "container_registry_region" {
  program = ["bash", "${path.module}/scripts/get-cr-region.sh"]

  query = {
    RESOURCE_GROUP_ID = module.resource_group.resource_group_id
    REGION            = var.region
    IBMCLOUD_API_KEY  = var.ibmcloud_api_key
  }
}

module "build" {
  depends_on         = [module.secret]
  source             = "../../modules/build"
  for_each           = local.updated_builds
  project_id         = module.project.project_id
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

resource "null_resource" "run_build" {
  depends_on = [module.build]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/build-run.sh"
    environment = {
      IBMCLOUD_API_KEY  = var.ibmcloud_api_key
      RESOURCE_GROUP_ID = module.resource_group.resource_group_id
      CE_PROJECT_NAME   = module.project.name
      REGION            = var.region
      BUILDS            = join(" ", keys(local.updated_builds))
    }
  }
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
module "domain_mapping" {
  depends_on = [module.secret]
  source     = "../../modules/domain_mapping"
  for_each   = var.domain_mappings
  project_id = module.project.project_id
  name       = each.key
  tls_secret = each.value.tls_secret
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
  # if the secret is a registry type, inject generated credentials (username, password, server) if they're not already provided.
  secrets = {
    for name, secret in var.secrets :
    name => merge(
      secret,
      {
        data = (
          secret.format == "registry"
          ? merge(secret.data, {
            password = lookup(secret.data, "password", var.ibmcloud_api_key),
            username = lookup(secret.data, "username", "iamapikey"),
            server   = lookup(secret.data, "server", local.container_registry)
          })
          : secret.data
        )
      }
    )
  }
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
