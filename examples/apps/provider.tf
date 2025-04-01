########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
  visibility       = "private"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
  alias            = "ibm-sm"
  visibility       = "private"
}
