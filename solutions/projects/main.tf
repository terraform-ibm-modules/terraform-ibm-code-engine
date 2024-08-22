########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.6"
  resource_group_name          = var.existing_resource_group == false ? var.resource_group_name : null
  existing_resource_group_name = var.existing_resource_group == true ? var.resource_group_name : null
}

########################################################################################################################
# Code Engine Projects
########################################################################################################################

module "project" {
  for_each          = toset(var.project_names)
  source            = "../../modules/project"
  name              = each.value
  resource_group_id = module.resource_group.resource_group_id
}
