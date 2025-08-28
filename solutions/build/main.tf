locals {
  prefix       = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  project_name = "${local.prefix}${var.project_name}"
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

  image_container = var.output_image == null && local.container_registry != null ? "${local.container_registry}/${resource.ibm_cr_namespace.my_namespace[0].name}" : ""
  output_image    = var.output_image != null ? var.output_image : "${local.image_container}/${var.build_name}"
}

resource "ibm_cr_namespace" "my_namespace" {
  count = var.output_image == null && var.container_registry_namespace != null ? 1 : 0
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
  depends_on                 = [module.secret]
  source                     = "../../modules/build"
  ibmcloud_api_key           = var.ibmcloud_api_key
  project_id                 = module.project.project_id
  name                       = var.build_name
  output_image               = local.output_image
  output_secret              = local.registry_secret_name
  source_url                 = var.source_url
  strategy_type              = var.strategy_type
  source_context_dir         = var.source_context_dir
  source_revision            = var.source_revision
  source_type                = var.source_type
  source_secret              = var.github_password != null && var.github_username != null ? local.github_secret_name : null
  strategy_size              = var.strategy_size
  strategy_spec_file         = var.strategy_spec_file
  timeout                    = var.timeout
  region                     = var.region
  existing_resource_group_id = module.resource_group.resource_group_id

}

##############################################################################
# Code Engine Secret
##############################################################################
locals {
  github_secret_name = "${local.prefix}github-secret"
  github_secret = var.github_password != null && var.github_username != null ? {
    (local.github_secret_name) = {
      format = "generic"
      "data" = {
        "password" = var.github_password,
        username   = var.github_username
      }
    }
  } : {}

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
  secrets = merge(local.registry_secret, local.github_secret)
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
