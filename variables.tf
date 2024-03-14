########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "ID of the resource group to use when creating resources."
  type        = string
}

variable "project_name" {
  description = "The name of the project to which code engine resources will be added."
  type        = string
}

variable "apps" {
  description = "A map of code engine apps to be created."
  type = map(object({
    image_reference = string
    run_env_variables = optional(list(object({
      type  = string
      name  = string
      value = string
    })))
  }))
  default = {}
}

variable "jobs" {
  description = "A map of code engine jobs to be created."
  type = map(object({
    image_reference = string
    run_env_variables = optional(list(object({
      type  = string
      name  = string
      value = string
    })))
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
  }))
  default = {}
}

variable "builds" {
  description = "A map of code engine builds to be created."
  type = map(object({
    output_image  = string
    output_secret = string # pragma: allowlist secret
    source_url    = string
    strategy_type = string
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
