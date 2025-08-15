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
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-0205-cos. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

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
    condition     = length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
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
  description = "The name of the project to add the IBM Cloud Code Engine. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<project_name>` format."
  type        = string
  default     = "ce-project"
}

##############################################################################
# Code Engine Domain Mapping
##############################################################################
variable "domain_mappings" {
  description = "A map of the IBM Cloud Code Engine domain mappings to create. For example, `{ domain_mapping_name: {tls_secret: 'tls_secret_name', components: [{ name : 'app_name', resource_type: 'app_v2'}]}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-inputs.md#domain_mappings)" # pragma: allowlist secret
  type = map(object({
    tls_secret = optional(string)
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
# variable "secrets" {
#   description = "A map of the IBM Cloud Code Engine secrets to create. For example, `{ secret_name: {format: 'generic', data: {key_1: 'value_1' }}}`.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-inputs.md#secrets)"
#   type = map(object({
#     format = string
#     data   = map(string)
#     # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
#     # service_access = optional(list(object({
#     #   resource_key = list(object({
#     #     id = optional(string)
#     #   }))
#     #   role = list(object({
#     #     crn = optional(string)
#     #   }))
#     #   service_instance = list(object({
#     #     id = optional(string)
#     #   }))
#     # })))
#   }))
#   default = {}
# }

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

##############################################################################
# Code Engine App
##############################################################################

# variable "app" {
#   description = "Details of code engine app to be created"

#   type = object({
#     image_reference = optional(string)
#     image_secret    = optional(string)
#     name            = string
#     run_env_variables = optional(list(object({
#       type      = optional(string)
#       name      = optional(string)
#       value     = optional(string)
#       prefix    = optional(string)
#       key       = optional(string)
#       reference = optional(string)
#     })))
#     run_volume_mounts = optional(list(object({
#       mount_path = string
#       reference  = string
#       name       = optional(string)
#       type       = string
#     })))
#     image_port                    = optional(number)
#     managed_domain_mappings       = optional(string)
#     run_arguments                 = optional(list(string))
#     run_as_user                   = optional(number)
#     run_commands                  = optional(list(string))
#     run_service_account           = optional(string)
#     scale_concurrency             = optional(number)
#     scale_concurrency_target      = optional(number)
#     scale_cpu_limit               = optional(string)
#     scale_ephemeral_storage_limit = optional(string)
#     scale_initial_instances       = optional(number)
#     scale_max_instances           = optional(number)
#     scale_memory_limit            = optional(string)
#     scale_min_instances           = optional(number)
#     scale_request_timeout         = optional(number)
#     scale_down_delay              = optional(number)
#   })

#   default = {
#     name = "application-ec"
#     image_reference : "icr.io/codeengine/helloworld"
#   }
# }

variable "app_name" {
  description = "The name of the application to be created and managed. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<app_name>` format. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads)"
  type        = string
  default     = "my-ce-app"
}

variable "app_image_reference" {
  description = "A container image can be identified by a container image reference with the following structure: registry / namespace / repository:tag. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)"
  type        = string
  default     = "icr.io/codeengine/helloworld"
}

variable "app_image_secret" {
  description = "The name of the access secret that is used for the image registry."
  type        = string
  default     = null
}

variable "app_scale_cpu_memory" {
  description = "Define the amount of CPU and memory resources for each instance. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo)"
  type        = string
  default     = "1 vCPU / 4 GB"
}

variable "app_image_port" {
  description = "The port which is used to connect to the port that is exposed by the container image."
  type        = number
  default     = 8080
}

variable "managed_domain_mappings" {
  description = "Define which of the following values for the system-managed domain mappings to set up for the application. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads#optionsvisibility)"
  type        = string
  default     = "local_public"
  validation {
    condition     = var.managed_domain_mappings == null || can(regex("local_public|local_private|local", var.managed_domain_mappings))
    error_message = "Valid values are 'local_public', 'local_private', or 'local'."
  }
}

variable "app_scale_cpu_limit" {
  description = "The number of CPUs to set for the instance of the app."
  type        = string
  default     = "1"
}

variable "app_scale_memory_limit" {
  description = "The amount of memory set for the instance of the app."
  type        = string
  default     = "4G"
}

variable "app_scale_ephemeral_storage_limit" {
  description = <<EOT
The amount of ephemeral storage to set for the instance of the app.
The units for specifying ephemeral storage are Megabyte (M) or Gigabyte (G), whereas G and M are the shorthand expressions for GB and MB. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-mem-cpu-combo#unit-measurements)


The value must match regular expression '/^([0-9.]+)([eEinumkKMGTPB]*)$/'.
EOT
  type        = string
  default     = "400M"
}

variable "app_scale_concurrency" {
  description = "The maximum number of requests that can be processed concurrently per instance."
  type        = number
  default     = 100
}

variable "app_scale_concurrency_target" {
  description = "The threshold of concurrent requests per instance at which one or more additional instances are created."
  type        = number
  default     = null
}

variable "app_scale_request_timeout" {
  description = "The amount of time in seconds that is allowed for a running app to respond to a request."
  type        = number
  default     = 300
}

variable "app_scale_down_delay" {
  description = "The amount of time in seconds that delays the scale-down behavior for an app instance."
  type        = number
  default     = 0
}

##############################################################################
# Code Engine Bindings
##############################################################################

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
