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

##############################################################################
# Code Engine Build
##############################################################################
module "build" {
  depends_on         = [module.secret]
  source             = "../../modules/build"
  for_each           = var.builds
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
module "secret" {
  source     = "../../modules/secret"
  for_each   = var.secrets
  project_id = module.project.project_id
  name       = each.key
  data       = sensitive(each.value.data)
  format     = each.value.format
  # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
  # service_access = each.value.service_access
}
