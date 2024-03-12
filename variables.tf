########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "ID of resource group to use when creating resources"
  type        = string
}

########################################################################################################################
# Code Engine
########################################################################################################################

variable "code_engine" {
  description = "A map describing code engine resources to be created."
  type = map(object({
    apps = optional(list(object({
      name            = string
      image_reference = string
      run_env_variables = optional(list(object({
        type  = string
        name  = string
        value = string
      })))
    }))),
    jobs = optional(list(object({
      name            = string
      image_reference = string
      run_env_variables = optional(list(object({
        type  = string
        name  = string
        value = string
      })))
    }))),
    config_maps = optional(list(object({
      name = string
      data = optional(map(string))
    }))),
    secrets = optional(list(object({
      name   = string
      format = string
      data   = optional(map(string))
    }))),
    builds = optional(list(object({
      name          = string
      output_image  = string
      output_secret = string # pragma: allowlist secret
      source_url    = string
      strategy_type = string
    })))
    bindings = optional(list(object({
      prefix      = string
      secret_name = string # pragma: allowlist secret
      components = list(object({
        name          = string
        resource_type = string
      }))
    })))
    domain_mappings = optional(list(object({
      name = string
      components = list(object({
        name          = string
        resource_type = string
      }))
      tls_secret = string
    })))
  }))
}
