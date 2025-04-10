########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}
variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}
variable "prefix" {
  type        = string
  description = "Prefix added to the project created by this solution (e.g `prod`, `test`, `dev`). To not use any prefix value, you can set this value to `null` or an empty string."
  nullable    = true
}

variable "region" {
  type        = string
  description = "The region in which to provision all resources created by this solution."
  default     = "us-south"
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources."
  default     = "Default"
}

variable "project_name" {
  description = "The name of the project to add the IBM Cloud Code Engine."
  type        = string
}

##############################################################################
# Code Engine Build
##############################################################################
variable "builds" {
  description = "A map of code engine builds to be created.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-inputs.md#builds)"
  type = map(object({
    output_image       = string
    output_secret      = string # pragma: allowlist secret
    source_url         = string
    strategy_type      = string
    source_context_dir = optional(string)
    source_revision    = optional(string)
    source_secret      = optional(string)
    source_type        = optional(string)
    strategy_size      = optional(string)
    strategy_spec_file = optional(string)
    timeout            = optional(number)
  }))
  default = {}
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
variable "domain_mappings" {
  description = "A map of the IBM Cloud Code Engine domain mappings to create. For example, `{ domain_mapping_name: {tls_secret: 'tls_secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-inputs.md#domain_mappings)" # pragma: allowlist secret
  type = map(object({
    tls_secret = string # pragma: allowlist secret
    components = list(object({
      name          = string
      resource_type = string
    }))
  }))
  default = {}
}

##############################################################################
# Code Engine Config Map
##############################################################################
variable "config_maps" {
  description = "A map of the IBM Cloud Code Engine configmaps to create. For example, `{ configmap_name: {data: {key_1: 'value_1' }}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-inputs.md#config_maps)"
  type = map(object({
    data = map(string)
  }))
  default = {}
}

##############################################################################
# Code Engine Secret
##############################################################################
variable "secrets" {
  description = "A map of the IBM Cloud Code Engine secrets to create. For example, `{ secret_name: {format: 'generic', data: {key_1: 'value_1' }}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-inputs.md#secrets)"
  type = map(object({
    format = string
    data   = map(string)
    # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
    # service_access = optional(list(object({
    #   resource_key = list(object({
    #     id = optional(string)
    #   }))
    #   role = list(object({
    #     crn = optional(string)
    #   }))
    #   service_instance = list(object({
    #     id = optional(string)
    #   }))
    # })))
  }))
  default = {}
}

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "The list of context-based restrictions rules to create.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-cbr_rules.md)"
  default     = []
}
