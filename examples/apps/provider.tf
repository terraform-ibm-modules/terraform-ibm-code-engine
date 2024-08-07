########################################################################################################################
# Provider config
########################################################################################################################

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
  alias            = "ibm-sm"
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "us-south"
  alias            = "ibm-cr"
}
