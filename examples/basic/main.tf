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
# Public cert used for secret
########################################################################################################################

data "ibm_sm_public_certificate" "public_certificate" {
  instance_id = var.secret_manager_id
  region      = var.secret_manager_region
  secret_id   = var.public_cert_id
}

########################################################################################################################
# Code Engine instance
########################################################################################################################

module "code_engine" {
  source            = "../.."
  resource_group_id = module.resource_group.resource_group_id
  project_name      = "${var.prefix}-project"
  apps = {
    "${var.prefix}-app" = {
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
    },
    "${var.prefix}-app2" = {
      image_reference = "icr.io/codeengine/helloworld"
    }
  }
  jobs = {
    "${var.prefix}-job" = {
      image_reference = "icr.io/codeengine/helloworld"
      run_env_variables = [{
        type  = "literal"
        name  = "name_1"
        value = "value_1"
      }]
    }
  }
  config_maps = {
    "${var.prefix}-cm" = {
      data = { "key_1" : "value_1", "key_2" : "value_2" }
    }
  }
  secrets = {
    "${var.prefix}-s" = {
      format = "generic"
      data   = { "key_1" : "value_1", "key_2" : "value_2" }
    },
    "${var.prefix}-tls" = {
      format = "tls"
      data = {
        "tls_cert" = format("%s%s", data.ibm_sm_public_certificate.public_certificate.certificate, data.ibm_sm_public_certificate.public_certificate.intermediate)
        "tls_key"  = data.ibm_sm_public_certificate.public_certificate.private_key
      }
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
  domain_mappings = {
    "goldeneye.dev.cloud.ibm.com" = {
      components = [{
        name          = "${var.prefix}-app"
        resource_type = "app_v2"
      }]
      tls_secret = "${var.prefix}-tls"
    }
  }
}
