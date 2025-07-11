module "code_engine" {
  source                       = "../app-from-source"
  ibmcloud_api_key             = var.ibmcloud_api_key
  prefix                       = var.prefix
  app                          = var.app
  secrets                      = var.secrets
  config_maps                  = var.config_maps
  domain_mappings              = var.domain_mappings
  cbr_rules                    = var.cbr_rules
  project_name                 = var.project_name
  provider_visibility          = var.provider_visibility
  existing_resource_group_name = var.existing_resource_group_name
  builds                       = {}
  bindings                     = var.bindings
  region                       = var.region
}
