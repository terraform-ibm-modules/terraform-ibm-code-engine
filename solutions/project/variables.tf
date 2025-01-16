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
  description = "Prefix to added to all project created by this solution."
  default     = null
  nullable    = true
}

variable "region" {
  type        = string
  description = "The region in which to provision all resources created by this solution."
  default     = "us-south"
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group to provision the IBM Cloud Code Engine resources to."
}

variable "project_name" {
  description = "The name of the project to add the IBM Cloud Code Engine."
  type        = string
}

##############################################################################
# Code Engine Build
##############################################################################
variable "output_image" {
  description = "The name of the image which includes the whole container regsitry repository, namespace and image name. For example, `us.icr.io/<test>-namespace/<test-image>`"
  type        = string
  default     = null
}

variable "output_secret" {
  description = "The secret that is required to access the image registry."
  type        = string
  default     = null
}

variable "source_context_dir" {
  description = "The directory in the repository that contains the buildpacks file or the Dockerfile."
  type        = string
  default     = null
}

variable "source_revision" {
  description = "Commit, tag, or branch in the source repository to pull."
  type        = string
  default     = null
}

variable "source_secret" {
  description = "The name of the secret that is used access the repository source. If the var.source_type value is `local`, this field must be omitted."
  type        = string
  default     = null
}

variable "source_type" {
  description = "Specifies the type of source to determine if your build source is in a repository or based on local source code."
  type        = string
  default     = null
}

variable "source_url" {
  description = "The URL of the code repository."
  type        = string
  default     = null
}

variable "strategy_size" {
  description = "The size for the build, which determines the amount of resources used."
  type        = string
  default     = null
}

variable "strategy_spec_file" {
  description = "The path to the specification file that is used for build strategies for building an image."
  type        = string
  default     = null
}

variable "strategy_type" {
  description = "The strategy to use for building the image."
  type        = string
  default     = "dockerfile"
}

variable "timeout" {
  description = "The maximum amount of time, in seconds, that can pass before the build must succeed or fail."
  type        = number
  default     = 600
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
variable "domain_mappings" {
  description = "A map of the IBM Cloud Code Engine domain mappings to create. For example, `{ domain_mapping_name: {tls_secret: 'tls_secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}`." # pragma: allowlist secret
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
  description = "A map of the IBM Cloud Code Engine configmaps to create. For example, `{ configmap_name: {data: {key_1: 'value_1' }}}`."
  type = map(object({
    data = map(string)
  }))
  default = {}
}

##############################################################################
# Code Engine Secret
##############################################################################
variable "secrets" {
  description = "A map of the IBM Cloud Code Engine secrets to create. For example, `{ secret_name: {format: 'generic', data: {key_1: 'value_1' }}}`."
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
