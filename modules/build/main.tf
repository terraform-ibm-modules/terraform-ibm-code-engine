##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine build
##############################################################################

locals {
  prefix = var.prefix != null ? (trimspace(var.prefix) != "" ? "${var.prefix}-" : "") : ""
}

resource "ibm_code_engine_build" "ce_build" {
  project_id         = var.project_id
  name               = var.name
  output_image       = local.output_image
  output_secret      = var.output_secret != null ? var.output_secret : module.secret[0].name
  source_url         = var.source_url
  source_context_dir = var.source_context_dir
  source_revision    = var.source_revision
  source_secret      = var.source_secret
  source_type        = var.source_type
  strategy_type      = var.strategy_type
  strategy_size      = var.strategy_size
  strategy_spec_file = var.strategy_spec_file
  timeout            = var.timeout
}

data "ibm_code_engine_project" "code_engine_project" {
  project_id = var.project_id
}

resource "terraform_data" "run_build" {
  depends_on = [ibm_code_engine_build.ce_build]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/build-run.sh"
    environment = {
      IBMCLOUD_API_KEY  = var.ibmcloud_api_key
      RESOURCE_GROUP_ID = var.existing_resource_group_id
      CE_PROJECT_NAME   = data.ibm_code_engine_project.code_engine_project.name
      REGION            = var.region
      BUILD_NAME        = ibm_code_engine_build.ce_build.name
    }
  }
}


##############################################################################
# Container Registry
##############################################################################

locals {
  create_cr_namespace = var.output_image == null && var.container_registry_namespace != null ? true : false
  image_container     = local.create_cr_namespace ? "${module.cr_endpoint[0].container_registry_endpoint_private}/${module.cr_namespace[0].namespace_name}" : null
  output_image        = local.create_cr_namespace ? "${local.image_container}/${var.name}" : var.output_image
}

module "cr_namespace" {
  count             = local.create_cr_namespace ? 1 : 0
  source            = "terraform-ibm-modules/container-registry/ibm"
  version           = "2.1.0"
  namespace_name    = "${local.prefix}${var.container_registry_namespace}"
  resource_group_id = var.existing_resource_group_id
}

module "cr_endpoint" {
  count   = local.create_cr_namespace ? 1 : 0
  source  = "terraform-ibm-modules/container-registry/ibm//modules/endpoint"
  version = "2.1.0"
  region  = var.region
}

##############################################################################
# Code Engine Secret
##############################################################################

module "secret" {
  count      = var.output_secret == null ? 1 : 0
  source     = "../../modules/secret"
  project_id = var.project_id
  name       = "${local.prefix}registry-access-secret"
  data = {
    password = var.container_registry_api_key != null ? var.container_registry_api_key : var.ibmcloud_api_key,
    username = "iamapikey",
    server   = module.cr_endpoint[0].container_registry_endpoint_private
  }
  format = "registry"
}
