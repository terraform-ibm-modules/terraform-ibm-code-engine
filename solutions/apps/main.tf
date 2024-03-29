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
  apps                = var.apps
  config_maps         = var.config_maps
  secrets             = var.secrets
  domain_mappings     = var.domain_mappings
  bindings            = var.bindings
}
