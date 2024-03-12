
locals {

  apps = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for app in(var.code_engine[project.name].apps != null ? var.code_engine[project.name].apps : []) : merge(app, { project_id = project.id })
    ]
  ])
  jobs = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for job in(var.code_engine[project.name].jobs != null ? var.code_engine[project.name].jobs : []) : merge(job, { project_id = project.id })
    ]
  ])
  config_maps = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for config_map in(var.code_engine[project.name].config_maps != null ? var.code_engine[project.name].config_maps : []) : merge(config_map, { project_id = project.id })
    ]
  ])
  secrets = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for secret in(var.code_engine[project.name].secrets != null ? var.code_engine[project.name].secrets : []) : merge(secret, { project_id = project.id })
    ]
  ])
  builds = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for build in(var.code_engine[project.name].builds != null ? var.code_engine[project.name].builds : []) : merge(build, { project_id = project.id })
    ]
  ])
  bindings = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for binding in(var.code_engine[project.name].bindings != null ? var.code_engine[project.name].bindings : []) : merge(binding, { project_id = project.id })
    ]
  ])
  domain_mappings = flatten([
    for project in resource.ibm_code_engine_project.ce_project : [
      for domain_mapping in(var.code_engine[project.name].domain_mappings != null ? var.code_engine[project.name].domain_mappings : []) : merge(domain_mapping, { project_id = project.id })
    ]
  ])
}

##############################################################################
# Code Engine Project
##############################################################################
resource "ibm_code_engine_project" "ce_project" {
  for_each          = var.code_engine
  name              = each.key
  resource_group_id = var.resource_group_id
}

##############################################################################
# Code Engine App
##############################################################################
resource "ibm_code_engine_app" "ce_app" {
  count           = length(local.apps)
  project_id      = local.apps[count.index].project_id
  name            = local.apps[count.index].name
  image_reference = local.apps[count.index].image_reference

  dynamic "run_env_variables" {
    for_each = local.apps[count.index].run_env_variables != null ? local.apps[count.index].run_env_variables : []
    content {
      type  = run_env_variables.value["type"]
      name  = run_env_variables.value["name"]
      value = run_env_variables.value["value"]
    }
  }
}

##############################################################################
# Code Engine Job
##############################################################################
resource "ibm_code_engine_job" "ce_job" {
  count           = length(local.jobs)
  project_id      = local.jobs[count.index].project_id
  name            = local.jobs[count.index].name
  image_reference = local.jobs[count.index].image_reference

  dynamic "run_env_variables" {
    for_each = local.jobs[count.index].run_env_variables != null ? local.jobs[count.index].run_env_variables : []
    content {
      type  = run_env_variables.value["type"]
      name  = run_env_variables.value["name"]
      value = run_env_variables.value["value"]
    }
  }
}

##############################################################################
# Code Engine Config Map
##############################################################################
resource "ibm_code_engine_config_map" "ce_config_map" {
  count      = length(local.config_maps)
  project_id = local.config_maps[count.index].project_id
  name       = local.config_maps[count.index].name
  data       = local.config_maps[count.index].data
}

##############################################################################
# Code Engine Secret
##############################################################################
resource "ibm_code_engine_secret" "code_engine_secret_instance" {
  count      = length(local.secrets)
  project_id = local.secrets[count.index].project_id
  name       = local.secrets[count.index].name
  format     = local.secrets[count.index].format
  data       = local.secrets[count.index].data
}

##############################################################################
# Code Engine Build
##############################################################################
resource "ibm_code_engine_build" "ce_build" {
  count         = length(local.builds)
  project_id    = local.builds[count.index].project_id
  name          = local.builds[count.index].name
  output_image  = local.builds[count.index].output_image
  output_secret = local.builds[count.index].output_secret
  source_url    = local.builds[count.index].source_url
  strategy_type = local.builds[count.index].strategy_type
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
resource "ibm_code_engine_domain_mapping" "ce_domain_mapping" {
  count      = length(local.domain_mappings)
  project_id = local.domain_mappings[count.index].project_id
  name       = local.domain_mappings[count.index].name
  tls_secret = local.domain_mappings[count.index].tls_secret
  dynamic "component" {
    for_each = local.domain_mappings[count.index].components != null ? local.domain_mappings[count.index].components : []
    content {
      name          = component.value["name"]
      resource_type = component.value["resource_type"]
    }
  }
}

##############################################################################
# Code Engine Binding
##############################################################################
resource "ibm_code_engine_binding" "ce_binding" {
  count       = length(local.bindings)
  project_id  = local.bindings[count.index].project_id
  prefix      = local.bindings[count.index].prefix
  secret_name = local.bindings[count.index].secret_name
  dynamic "component" {
    for_each = local.bindings[count.index].components != null ? local.bindings[count.index].components : []
    content {
      name          = component.value["name"]
      resource_type = component.value["resource_type"]
    }
  }
}
