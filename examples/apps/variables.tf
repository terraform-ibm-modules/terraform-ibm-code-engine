########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API Key"
  sensitive   = true
}

variable "region" {
  type        = string
  description = "Region to provision all resources created by this example"
  default     = "us-south"
}

variable "prefix" {
  type        = string
  description = "Prefix to append to all resources created by this example"
  default     = "ce-apps"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

##############################################################
# Secret Manager
##############################################################

variable "sm_service_plan" {
  type        = string
  description = "The service/pricing plan to use when provisioning a new Secrets Manager instance. Allowed values: `standard` and `trial`. Only used if `provision_sm_instance` is set to true."
  default     = "standard"
}

variable "existing_sm_instance_guid" {
  type        = string
  description = "An existing Secrets Manager GUID. The existing Secret Manager instance must have private certificate engine configured. If not provided an new instance will be provisioned."
  default     = null
}

variable "existing_sm_instance_region" {
  type        = string
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  default     = null
}

variable "existing_cert_common_name" {
  type        = string
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  default     = null
}

variable "existing_cert_secret_id" {
  type        = string
  description = "Required if value is passed into `var.existing_sm_instance_guid`."
  default     = null
}

variable "cis_id" {
  type        = string
  description = "Cloud Internet Service ID"
  default     = null
}

variable "dns_provider_name" {
  type        = string
  description = "Secret Managers DNS provider name"
  default     = "certificate-dns"
}

variable "private_key_secrets_manager_instance_guid" {
  type        = string
  description = "The Secrets Manager instance GUID of the Secrets Manager containing your ACME private key. Required if acme_letsencrypt_private_key is not set."
  default     = null
}

variable "private_key_secrets_manager_secret_id" {
  type        = string
  description = "The secret ID of your ACME private key. Required if acme_letsencrypt_private_key is not set. If both are set, this value will be used as the private key."
  default     = null
}

variable "private_key_secrets_manager_region" {
  type        = string
  description = "The region of the Secrets Manager instance containing your ACME private key. (Only needed if different from the region variable)"
  default     = "us-south"
}

variable "ca_name" {
  type        = string
  description = "Secret Managers certificate authority name"
  default     = "certificate-ca"
}

variable "acme_letsencrypt_private_key" {
  type        = string
  description = "Lets Encrypt private key for certificate authority. If not provided, all created public certs will be immediately deactivated."
  default     = null
  sensitive   = true
}
