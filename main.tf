##############################################################################
# Code Engine Project
##############################################################################
module "project" {
  source            = "./modules/project"
  name              = var.project_name
  resource_group_id = var.resource_group_id
}

##############################################################################
# Code Engine App
##############################################################################
module "app" {
  source            = "./modules/app"
  for_each          = var.apps
  project_id        = module.project.id
  name              = each.key
  image_reference   = each.value.image_reference
  run_env_variables = each.value.run_env_variables
}

##############################################################################
# Code Engine Job
##############################################################################
module "job" {
  source            = "./modules/job"
  for_each          = var.jobs
  project_id        = module.project.id
  name              = each.key
  image_reference   = each.value.image_reference
  run_env_variables = each.value.run_env_variables
}

##############################################################################
# Code Engine Config Map
##############################################################################
module "config_map" {
  source     = "./modules/config_map"
  for_each   = var.config_maps
  project_id = module.project.id
  name       = each.key
  data       = each.value.data
}

##############################################################################
# Code Engine Secret
##############################################################################
module "secret" {
  source     = "./modules/secret"
  for_each   = var.secrets
  project_id = module.project.id
  name       = each.key
  data       = each.value.data
  format     = each.value.format
}

##############################################################################
# Code Engine Build
##############################################################################
module "build" {
  source        = "./modules/build"
  for_each      = var.builds
  project_id    = module.project.id
  name          = each.key
  output_image  = each.value.output_image
  output_secret = each.value.output_secret
  source_url    = each.value.source_url
  strategy_type = each.value.strategy_type
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
module "domain_mapping" {
  source     = "./modules/domain_mapping"
  for_each   = var.domain_mappings
  project_id = module.project.id
  name       = each.key
  tls_secret = each.value.tls_secret
  components = each.value.components
}

##############################################################################
# Code Engine Binding
##############################################################################
module "binding" {
  source      = "./modules/binding"
  for_each    = var.bindings
  project_id  = module.project.id
  prefix      = each.key
  secret_name = each.value.secret_name
  components  = each.value.components
}
