########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Code Engine project
########################################################################################################################

module "ce_project" {
  source            = "../../modules/project"
  resource_group_id = module.resource_group.resource_group_id
  name              = "${var.prefix}-project"
}

########################################################################################################################
# Code Engine app
########################################################################################################################

locals {
  apps = {
    "${var.prefix}-app-1" = {
      image_reference   = "icr.io/codeengine/helloworld"
      run_env_variables = []
    },
    "${var.prefix}-app-2" = {
      image_reference   = "icr.io/codeengine/helloworld"
      run_env_variables = [{ type = "literal", name = "env_variable_1", value = "env_value" }]
    }
  }
}
module "ce_app" {
  source            = "../../modules/app"
  for_each          = local.apps
  name              = each.key
  project_id        = module.ce_project.project_id
  image_reference   = each.value.image_reference
  run_env_variables = each.value.run_env_variables
}
