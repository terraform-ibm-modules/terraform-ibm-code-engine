########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Code Engine instance
########################################################################################################################

module "code_engine" {
  source            = "../.."
  ibmcloud_api_key  = var.ibmcloud_api_key
  resource_group_id = module.resource_group.resource_group_id
  project_name      = "${var.prefix}-project"
  builds = {
    "${var.prefix}-build1" = {
      source_url                   = "https://github.com/IBM/CodeEngine"
      container_registry_namespace = "cr-ce"
      prefix                       = var.prefix
      region                       = var.region
    }
  }
}
