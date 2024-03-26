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
  default     = "ce-basic"
}

variable "resource_group" {
  type        = string
  description = "The name of an existing resource group to provision resources in to. If not set a new resource group will be created using the prefix variable"
  default     = null
}

variable "secret_manager_id" {
  type        = string
  description = "The ID of secret manager."
}

variable "secret_manager_region" {
  type        = string
  description = "The region where secret manager is provisioned."
}

variable "public_cert_id" {
  type        = string
  description = "The ID of public certificate."
}
