########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.5"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Code Engine instance
########################################################################################################################

module "code_engine" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  code_engine = {
    "${var.prefix}-project_1" = {
      apps = [{
        name            = "${var.prefix}-app"
        image_reference = "icr.io/codeengine/helloworld"
      }],
      jobs = [{
        name            = "${var.prefix}-job"
        image_reference = "icr.io/codeengine/helloworld"
        run_env_variables = [{
          type  = "literal"
          name  = "name_1"
          value = "value_1"
          },
          {
            type  = "literal"
            name  = "name_2"
            value = "value_2"
        }]
      }],
      config_maps = [{
        name = "${var.prefix}-cm"
        data = { "key_1" : "value_1", "key_2" : "value_2" }
      }],
      secrets = [{
        name   = "${var.prefix}-s"
        format = "generic"
        data   = { "key_1" : "value_1", "key_2" : "value_2" }
      }],
      builds = [{
        name          = "${var.prefix}-build-1"
        output_image  = "private.de.icr.io/icr_namespace/image-name"
        output_secret = "icr-private" # pragma: allowlist secret
        source_url    = "https://github.com/IBM/CodeEngine"
        strategy_type = "dockerfile"
      }]
    },
    "${var.prefix}-project_2" = {
      apps = [{
        name            = "${var.prefix}-app-2"
        image_reference = "icr.io/codeengine/helloworld"
      }]
    }
  }
}
