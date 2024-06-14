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
# Secrets Manager resources
########################################################################################################################

locals {
  sm_guid   = var.existing_sm_instance_guid == null ? ibm_resource_instance.secrets_manager[0].guid : var.existing_sm_instance_guid
  sm_region = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region

  # Certificate issuance is rate limited by domain, by default pick different domains to avoid rate limits during testing
  cert_common_name = var.existing_cert_common_name == null ? "${var.prefix}.goldeneye.dev.cloud.ibm.com" : var.existing_cert_common_name
  cert_secret_id   = var.existing_cert_secret_id == null ? resource.ibm_sm_public_certificate.secrets_manager_public_certificate[0].secret_id : var.existing_cert_secret_id

}

# Create a new SM instance if not using an existing one
resource "ibm_resource_instance" "secrets_manager" {
  count             = var.existing_sm_instance_guid == null ? 1 : 0
  name              = "${var.prefix}-sm-instance"
  service           = "secrets-manager"
  plan              = var.sm_service_plan
  location          = local.sm_region
  resource_group_id = module.resource_group.resource_group_id
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
  provider = ibm.ibm-sm
}

# Configure public cert engine if provisioning a new SM instance
module "secrets_manager_public_cert_engine" {
  depends_on = [ibm_resource_instance.secrets_manager]
  count      = var.existing_sm_instance_guid == null ? 1 : 0
  source     = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version    = "1.0.1"
  providers = {
    ibm              = ibm.ibm-sm
    ibm.secret-store = ibm.ibm-sm
  }
  secrets_manager_guid                      = local.sm_guid
  region                                    = local.sm_region
  internet_services_crn                     = var.cis_id
  dns_config_name                           = var.dns_provider_name
  ca_config_name                            = var.ca_name
  acme_letsencrypt_private_key              = var.acme_letsencrypt_private_key
  private_key_secrets_manager_instance_guid = var.private_key_secrets_manager_instance_guid
  private_key_secrets_manager_secret_id     = var.private_key_secrets_manager_secret_id
  private_key_secrets_manager_region        = var.private_key_secrets_manager_region
}

# Create a secret group to place the certificate in
module "secrets_manager_group" {
  count                    = var.existing_cert_secret_id == null ? 1 : 0
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.2.2"
  region                   = local.sm_region
  secrets_manager_guid     = local.sm_guid
  secret_group_name        = "${var.prefix}-certificates-secret-group"
  secret_group_description = "secret group used for private certificates"
  providers = {
    ibm = ibm.ibm-sm
  }
}

resource "ibm_sm_public_certificate" "secrets_manager_public_certificate" {
  depends_on = [module.secrets_manager_public_cert_engine]
  count      = var.existing_cert_secret_id == null ? 1 : 0

  instance_id     = local.sm_guid
  region          = local.sm_region
  name            = local.cert_common_name
  description     = "Certificate for ${local.cert_common_name} domain"
  ca              = var.ca_name
  dns             = var.dns_provider_name
  common_name     = local.cert_common_name
  secret_group_id = module.secrets_manager_group[0].secret_group_id
  rotation {
    auto_rotate = true
  }
}

data "ibm_sm_public_certificate" "public_certificate" {
  depends_on  = [resource.ibm_sm_public_certificate.secrets_manager_public_certificate]
  instance_id = local.sm_guid
  region      = local.sm_region
  secret_id   = local.cert_secret_id
}

########################################################################################################################
# Code Engine instance
########################################################################################################################

module "code_engine" {
  depends_on        = [resource.ibm_sm_public_certificate.secrets_manager_public_certificate]
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
      scale_cpu_limit               = "4",
      scale_memory_limit            = "32G"
      scale_ephemeral_storage_limit = "300M"
      managed_domain_mappings       = "local_private"
    }
    "${var.prefix}-app2" = {
      image_reference = "icr.io/codeengine/helloworld"
    }
  }
  config_maps = {
    "${var.prefix}-cm" = {
      data = { "key_1" : "value_1", "key_2" : "value_2" }
    }
  }
  secrets = {
    "${var.prefix}-tls" = {
      format = "tls"
      data = {
        "tls_cert" = format("%s%s", data.ibm_sm_public_certificate.public_certificate.certificate, data.ibm_sm_public_certificate.public_certificate.intermediate)
        "tls_key"  = data.ibm_sm_public_certificate.public_certificate.private_key
      }
    }
  }
  domain_mappings = {
    # tflint-ignore: terraform_deprecated_interpolation
    "${local.cert_common_name}" = {
      components = [{
        name          = "${var.prefix}-app"
        resource_type = "app_v2"
      }]
      tls_secret = "${var.prefix}-tls"
    }
  }
}
