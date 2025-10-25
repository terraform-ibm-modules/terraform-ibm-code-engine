########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Secrets Manager resources
########################################################################################################################

data "ibm_sm_public_certificate" "public_certificate" {
  # depends_on  = [resource.ibm_sm_public_certificate.secrets_manager_public_certificate]
  instance_id = var.existing_sm_instance_guid
  region      = var.existing_sm_instance_region
  secret_id   = var.existing_cert_secret_id
}


module "namespace" {
  source            = "terraform-ibm-modules/container-registry/ibm"
  version           = "2.2.1"
  namespace_name    = "${var.prefix}-namespace"
  resource_group_id = module.resource_group.resource_group_id
  images_per_repo   = 1
}
