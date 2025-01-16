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
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "../../modules/project"
  name              = var.prefix != null ? "${var.prefix}-${var.project_name}" : var.project_name
  resource_group_id = module.resource_group.resource_group_id
}

##############################################################################
# Code Engine Build
##############################################################################
module "build" {
  depends_on         = [module.secret]
  count              = var.output_image != null && var.output_secret != null && var.source_url != null ? 1 : 0
  source             = "../../modules/build"
  project_id         = module.project.project_id
  name               = var.prefix != null ? "${var.prefix}-${var.project_name}" : var.project_name
  output_image       = var.output_image
  output_secret      = var.output_secret
  source_url         = var.source_url
  strategy_type      = var.strategy_type
  source_context_dir = var.source_context_dir
  source_revision    = var.source_revision
  source_secret      = var.source_secret
  source_type        = var.source_type
  strategy_size      = var.strategy_size
  strategy_spec_file = var.strategy_spec_file
  timeout            = var.timeout
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
