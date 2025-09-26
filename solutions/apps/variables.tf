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

variable "region" {
  type        = string
  description = "The region in which to provision all resources created by this solution."
  default     = "us-south"
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to add to all resources that this solution creates (e.g `prod`, `test`, `dev`). To skip using a prefix, set this value to null or an empty string. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources. If not provided the default resource group will be used."
  default     = null
}

variable "project_name" {
  description = "The name of the project to add the IBM Cloud Code Engine resources to. If the value of `var.existing_project_id` is `null`, the project name is required. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<project_name>` format."
  type        = string
  default     = null
}

variable "existing_project_id" {
  description = "The ID of the existing project to add the IBM Cloud Code Engine resources to. If the value of `var.project_name` is `null`, the project ID is required."
  type        = string
  default     = null
}

variable "app_name" {
  description = "The name of the application to be created and managed. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads)"
  type        = string
  default     = "my-ce-app"
}

variable "image_reference" {
  description = "A container image can be identified by a container image reference with the following structure: registry / namespace / repository:tag. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)"
  type        = string
  default     = "icr.io/codeengine/helloworld"
}

variable "image_secret" {
  description = "The name of the access secret that is used for the image registry."
  type        = string
  default     = null
}

variable "run_env_variables" {
  description = "References to configmaps, secrets, or literal values that are displayed as environment variables within the running application."
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
  description = "Optional. Mount targets for configmaps or secrets."
  type = list(object({
    mount_path = string
    reference  = string
    name       = optional(string)
    type       = string
  }))
  default = []
}

variable "image_port" {
  description = "The port number that is used to connect to the port displayed by the container image."
  type        = number
  default     = 8080
}

variable "managed_domain_mappings" {
  description = "Define which of the following values for the system-managed domain mappings to set up for the application: `local_public`, `local_private`, and `local`. See https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads#optionsvisibility"
  type        = string
  default     = null
  validation {
    condition     = var.managed_domain_mappings == null || can(regex("local_public|local_private|local", var.managed_domain_mappings))
    error_message = "Valid values are 'local_public', 'local_private', or 'local'."
  }
}

variable "run_arguments" {
  description = "The arguments for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_as_user" {
  description = "The user ID (UID) to run the app."
  type        = number
  default     = null
}

variable "run_commands" {
  description = "The commands for the app that are passed to start the container."
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
  description = "The threshold of concurrent requests per instance at which one or more extra instances are created."
  type        = number
  default     = null
}

variable "scale_cpu_limit" {
  description = "The number of CPUs to set for the instance of the app."
  type        = string
  default     = "1"
}

variable "scale_ephemeral_storage_limit" {
  description = "The amount of ephemeral storage to set for the instance of the app."
  type        = string
  default     = "400M"
}

variable "scale_initial_instances" {
  description = "The initial number of instances that are created during app creation or app update."
  type        = number
  default     = 1
}

variable "scale_max_instances" {
  description = "The maximum number of instances for the app."
  type        = number
  default     = 10
}

variable "scale_memory_limit" {
  description = "The amount of memory set for the instance of the app."
  type        = string
  default     = "4G"
}

variable "scale_min_instances" {
  description = "The minimum number of instances for the app. If you set this value to `0` and the app does not receive any requests, it will scale down to zero instances."
  type        = number
  default     = 0
}

variable "scale_request_timeout" {
  description = "The amount of time in seconds during which a running app can respond to a request."
  type        = number
  default     = 300
}

variable "scale_down_delay" {
  description = "The amount of time in seconds that delays the scale-down behavior for an app instance."
  type        = number
  default     = 0
}

variable "config_maps" {
  description = "A map of the IBM Cloud Code Engine configmaps to create. For example, `{ configmap_name: {data: {key_1: 'value_1' }}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/apps/DA-inputs.md#config_maps)"
  type = map(object({
    data = map(string)
  }))
  default = {}
}

variable "secrets" {
  description = "A map of the IBM Cloud Code Engine secrets to create. For example, `{ secret_name: {format: 'generic', data: {key_1: 'value_1' }}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/apps/DA-inputs.md#secrets)"
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
  description = "A map of the IBM Cloud Code Engine domain mappings to create. For example, `{ domain_mapping_name: {tls_secret: 'tls_secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/apps/DA-inputs.md#domain_mappings)" # pragma: allowlist secret
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
  description = "A map of the IBM Cloud Code Engine bindings to create. For example, `{ 'PREFIX': {secret_name: 'secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}`."
  type = map(object({
    secret_name = string
    components = list(object({
      name          = string
      resource_type = string
    }))
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
