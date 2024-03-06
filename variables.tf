########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "ID of resource group to use when creating the VPC and PAG"
  type        = string
}


########################################################################################################################
# Code Engine
########################################################################################################################

variable "code_engine" {
  description = ""
  type = map(object({
    apps = optional(list(object({
      name            = string
      image_reference = string
    }))),
    jobs = optional(list(object({
      name            = string
      image_reference = string
    }))),
    config_maps = optional(list(object({
      name = string
    }))),
    secrets = optional(list(object({
      name   = string
      format = string
    }))),
    builds = optional(list(object({
      name          = string
      output_image  = string
      output_secret = string
      source_url    = string
      strategy_type = string
    })))
    bindings = optional(list(object({
      prefix      = string
      secret_name = string
      component = list(object({
        name          = string
        resource_type = string
      }))
    })))
    domain_mappings = optional(list(object({
      name = string
      component = list(object({
        name          = string
        resource_type = string
      }))
      tls_secret = string
    })))

  }))
  default = {
    "project_11" = {
      apps = [{
        name            = "app-name1"
        image_reference = "icr.io/codeengine/helloworld"
        },
        {
          name            = "app-name2"
          image_reference = "icr.io/codeengine/helloworld"
      }],
      jobs = [{
        name            = "jobs-1"
        image_reference = "icr.io/codeengine/helloworld"
      }],
      config_maps = [{
        name = "config-map-1"
      }],
      secrets = [{
        name   = "secret-1"
        format = "generic"
      }],
      builds = [{
        name          = "build-1"
        output_image  = "private.de.icr.io/icr_namespace/image-name"
        output_secret = "ce-auto-icr-private-eu-de"
        source_url    = "https://github.com/IBM/CodeEngine"
        strategy_type = "dockerfile"
      }],
      domain_mappings = [{
        name = "domain_mapping-1"
        component = [{
          name          = "component-name"
          resource_type = "app_v2"
        }]
        tls_secret = "my-tls-secret"
      }],
      bindings = [{
        prefix = "BINDING_1"
        component = [{
          name          = "component-name"
          resource_type = "app_v2"
        }]
        secret_name = "my-service-access"
      }],
    },
    "project_22" = {
      apps = [{
        name            = "app-name1"
        image_reference = "icr.io/codeengine/helloworld"
      }]
    }
  }
}
