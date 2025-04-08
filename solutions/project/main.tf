########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.0"
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
