locals {
  # add prefix to all projects created by this solution if prefix is not null
  projects = [
    for project in var.project_names : (
      var.prefix != null ? "${var.prefix}-${project}" : project
    )
  ]
}

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
  count             = length(local.projects)
  source            = "../../modules/project"
  name              = local.projects[count.index]
  resource_group_id = module.resource_group.resource_group_id
  cbr_rules         = var.cbr_rules
}
