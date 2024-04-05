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
  description = "Region to provision all resources created by this solution."
  default     = "us-south"
}

variable "existing_resource_group" {
  type        = bool
  description = "Whether to use an existing resource group."
  default     = false
}

variable "resource_group_name" {
  type        = string
  description = "The name of a new or an existing resource group in which to provision the IBM Code Engine resources in."
}

variable "project_name" {
  description = "The name of the project to which code engine resources will be added. It is required if var.existing_project_id is null."
  type        = string
  default     = null
}

variable "existing_project_id" {
  description = "The ID of the existing project to which code engine resources will be added. It is required if var.project_name is null."
  type        = string
  default     = null
}

variable "app_name" {
  description = "The name of the app."
  type        = string
}

variable "image_reference" {
  description = "The name of the image that is used for the app."
  type        = string
}

variable "image_secret" {
  description = "The name of the image registry access secret."
  type        = string
  default     = null
}

variable "run_env_variables" {
  description = "References to config maps, secrets or a literal values that are exposed as environment variables within the running application."
  type = list(object({
    type      = optional(string)
    name      = optional(string)
    value     = optional(string)
    prefix    = optional(string)
    key       = optional(string)
    reference = optional(string)
  }))
  default = []
}

variable "run_volume_mounts" {
  description = "Optional mounts of config maps or a secrets."
  type = list(object({
    mount_path = string
    reference  = string
    name       = optional(string)
    type       = string
  }))
  default = []
}

variable "image_port" {
  description = "The port which is used to connect to the port that is exposed by the container image."
  type        = number
  default     = 8080
}

variable "managed_domain_mappings" {
  description = "Define which of the system managed domain mappings will be setup for the application. Valid values are 'local_public', 'local_private' and 'local'."
  type        = string
  default     = null
}

variable "run_arguments" {
  description = "Arguments for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_as_user" {
  description = "The user ID (UID) to run the app."
  type        = number
  default     = null
}

variable "run_commands" {
  description = "Commands for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_service_account" {
  description = "The name of the service account."
  type        = string
  default     = "default"
}

variable "scale_concurrency" {
  description = "The maximum number of requests that can be processed concurrently per instance."
  type        = number
  default     = 100
}

variable "scale_concurrency_target" {
  description = "The threshold of concurrent requests per instance at which one or more additional instances are created."
  type        = number
  default     = null
}

variable "scale_cpu_limit" {
  description = "The number of CPU set for the instance of the app."
  type        = string
  default     = "1"
}

variable "scale_ephemeral_storage_limit" {
  description = "The amount of ephemeral storage to set for the instance of the app."
  type        = string
  default     = "400M"
}

variable "scale_initial_instances" {
  description = "The initial number of instances that are created upon app creation or app update."
  type        = number
  default     = 1
}

variable "scale_max_instances" {
  description = "The maximum number of instances for this app."
  type        = number
  default     = 10
}

variable "scale_memory_limit" {
  description = "The amount of memory set for the instance of the app."
  type        = string
  default     = "4G"
}

variable "scale_min_instances" {
  description = "The minimum number of instances for this app.  If you set this value to 0, the app will scale down to zero, if not hit by any request for some time."
  type        = number
  default     = 0
}

variable "scale_request_timeout" {
  description = "The amount of time in seconds that is allowed for a running app to respond to a request."
  type        = number
  default     = 300
}

variable "config_maps" {
  description = "A map of code engine config maps to be created. Example: { configmap_name: {data: {key_1: 'value_1' }}}"
  type = map(object({
    data = map(string)
  }))
  default = {}
}

variable "secrets" {
  description = "A map of code engine secrets to be created. Example: { secret_name: {format: 'generic', data: {key_1: 'value_1' }}}"
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

variable "domain_mappings" {
  description = "A map of code engine domain mappings to be created. Example: { domain_mapping_name: {tls_secret: 'tls_secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}" # pragma: allowlist secret
  type = map(object({
    tls_secret = string # pragma: allowlist secret
    components = list(object({
      name          = string
      resource_type = string
    }))
  }))
  default = {}
}

variable "bindings" {
  description = "A map of code engine bindings to be created. Example: { 'PREFIX': {secret_name: 'secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}"
  type = map(object({
    secret_name = string
    components = list(object({
      name          = string
      resource_type = string
    }))
  }))
  default = {}
}
