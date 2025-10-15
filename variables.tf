########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "ID of the resource group to use when creating resources."
  type        = string
}

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key. Required only when 'builds' are specified and used."
  sensitive   = true
  default     = null
  # ibmcloud_api_key must be set only when var.builds is not empty to run the "build run"
  validation {
    condition     = length(var.builds) == 0 || var.ibmcloud_api_key != null
    error_message = "The 'ibmcloud_api_key' must be set if 'builds' is not empty to run the build process."
  }
  validation {
    condition     = (var.ibmcloud_api_key == null || length(var.builds) > 0)
    error_message = "If 'ibmcloud_api_key' is set, 'builds' must not be empty."
  }
}

variable "project_name" {
  description = "The name of the project to which code engine resources will be added. It is required if var.existing_project_id is null."
  type        = string
  default     = null
  validation {
    condition     = (var.project_name != null) != (var.existing_project_id != null)
    error_message = "Please provide exactly one of var.project_name or var.existing_project_id. Passing neither or both is invalid."
  }
}

variable "existing_project_id" {
  description = "The ID of the existing project to which code engine resources will be added. It is required if var.project_name is null."
  type        = string
  default     = null
}

variable "apps" {
  description = "A map of code engine apps to be created."
  type = map(object({
    image_reference = string
    image_secret    = optional(string)
    run_env_variables = optional(list(object({
      type      = optional(string)
      name      = optional(string)
      value     = optional(string)
      prefix    = optional(string)
      key       = optional(string)
      reference = optional(string)
    })))
    run_volume_mounts = optional(list(object({
      mount_path = string
      reference  = string
      name       = optional(string)
      type       = string
    })))
    image_port                    = optional(number)
    managed_domain_mappings       = optional(string)
    run_arguments                 = optional(list(string))
    run_as_user                   = optional(number)
    run_commands                  = optional(list(string))
    run_service_account           = optional(string)
    scale_concurrency             = optional(number)
    scale_concurrency_target      = optional(number)
    scale_cpu_limit               = optional(string)
    scale_ephemeral_storage_limit = optional(string)
    scale_initial_instances       = optional(number)
    scale_max_instances           = optional(number)
    scale_memory_limit            = optional(string)
    scale_min_instances           = optional(number)
    scale_request_timeout         = optional(number)
    scale_down_delay              = optional(number)
  }))
  default = {}
}


variable "jobs" {
  description = "A map of code engine jobs to be created."
  type = map(object({
    image_reference = string
    image_secret    = optional(string)
    run_env_variables = optional(list(object({
      type      = optional(string)
      name      = optional(string)
      value     = optional(string)
      prefix    = optional(string)
      key       = optional(string)
      reference = optional(string)
    })))
    run_volume_mounts = optional(list(object({
      mount_path = string
      reference  = string
      name       = optional(string)
      type       = string
    })))
    run_arguments                 = optional(list(string))
    run_as_user                   = optional(number)
    run_commands                  = optional(list(string))
    run_mode                      = optional(string)
    run_service_account           = optional(string)
    scale_array_spec              = optional(string)
    scale_cpu_limit               = optional(string)
    scale_ephemeral_storage_limit = optional(string)
    scale_max_execution_time      = optional(number)
    scale_memory_limit            = optional(string)
    scale_retry_limit             = optional(number)
  }))
  default = {}
}

variable "config_maps" {
  description = "A map of code engine config maps to be created."
  type = map(object({
    data = map(string)
  }))
  default = {}
}

variable "secrets" {
  description = "A map of code engine secrets to be created."
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

variable "builds" {
  description = "A map of code engine builds to be created. Requires 'ibmcloud_api_key' to be set for authentication and execution."
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

variable "domain_mappings" {
  description = "A map of code engine domain mappings to be created."
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
  description = "A map of code engine bindings to be created."
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
  description = "The list of context-based restrictions rules to create."
  default     = []
  validation {
    condition     = length(var.cbr_rules) <= 1
    error_message = "There should only be one rule."
  }
}
