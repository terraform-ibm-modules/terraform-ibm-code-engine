########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.1.6"
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
  region            = var.region
  project_name      = "${var.prefix}-project"
  jobs = {
    "${var.prefix}-job" = {
      image_reference = "icr.io/codeengine/helloworld"
      run_env_variables = [{
        type  = "literal"
        name  = "name_1"
        value = "value_1"
      }]
      run_mode                      = "task",
      scale_cpu_limit               = "4",
      scale_memory_limit            = "32G"
      scale_ephemeral_storage_limit = "300M"
      scale_max_execution_time      = 3000
      scale_retry_limit             = 2
      scale_array_spec              = "5"
      run_volume_mounts = [{
        mount_path = "/dir"
        name       = "volume",
        reference  = "${var.prefix}-s"
        type       = "secret"
      }]
      run_arguments = ["echo \"hello world\""]
      run_commands  = ["/bin/sh"]
    },
    "${var.prefix}-job-2" = {
      image_reference = "icr.io/codeengine/helloworld"
    }
  }
  secrets = {
    "${var.prefix}-s" = {
      format = "generic"
      data   = { "key_1" : "value_1", "key_2" : "value_2" }
    }
  }
  builds = {
    "${var.prefix}-build" = {
      output_image  = "private.de.icr.io/icr_namespace/image-name"
      output_secret = "icr-private" # pragma: allowlist secret
      source_url    = "https://github.com/IBM/CodeEngine"
      strategy_type = "dockerfile"
    }
  }
}
